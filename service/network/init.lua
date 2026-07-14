--- NetworkManager integration service.
-- Watches the NetworkManager D-Bus service for state changes and exposes a
-- Lua-side object model (clients, devices, connections, access points) that
-- the UI layer can iterate. When NetworkManager is unavailable (no DBus
-- service, missing permissions, headless boot), the service still loads but
-- exposes empty collections — UI code can guard with `if network.NM then …`.
-- @module service.network

local lgi = require("lgi")

-- Probe the NetworkManager GIR binding. The service degrades gracefully
-- (no D-Bus introspection) when NM is missing — UI code should check
-- `network.NM` before driving the API.
local NM
do
    local ok, mod = pcall(function()
        return require("lgi").NM
    end)
    if ok then
        NM = mod
    else
        -- Best-effort: log once via gears.debug if it's loaded; the rest of
        -- the module just sees `network.NM == nil` and skips the D-Bus wiring.
        pcall(function()
            require("gears.debug").print_warning(
                "service.network: NetworkManager GIR not available; service disabled"
            )
        end)
    end
end

local dbus_proxy = require("lib.dbus_proxy")
local gobject = require("gears.object")
local gtable = require("gears.table")

local network = {}
network.NM = NM -- Exposed for callers to test availability
local client = {}
local connection = {}
local wired = {}
local wireless = {}
local access_point = {}
local device = {}

-- @table network.NMState
-- Numeric state constants exposed by NetworkManager. Mirrors `NM.State` enum.
network.NMState = {
    UNKNOWN = 0,
    ASLEEP = 10,
    DISCONNECTED = 20,
    DISCONNECTING = 30,
    CONNECTING = 40,
    CONNECTED_LOCAL = 50,
    CONNECTED_SITE = 60,
    CONNECTED_GLOBAL = 70,
}

network.DeviceType = {
    ETHERNET = 1,
    WIFI = 2,
}

network.DeviceState = {
    UNKNOWN = 0,
    UNMANAGED = 10,
    UNAVAILABLE = 20,
    DISCONNECTED = 30,
    PREPARE = 40,
    CONFIG = 50,
    NEED_AUTH = 60,
    IP_CONFIG = 70,
    IP_CHECK = 80,
    SECONDARIES = 90,
    ACTIVATED = 100,
    DEACTIVATING = 110,
    FAILED = 120,
}

--- Convert a NetworkManager device state integer to a human-readable string.
-- @tparam integer state DeviceState enum value (0..120)
-- @treturn string Human-readable state name, or `nil` if unknown
-- @see network.NMState
function network.device_state_to_string(state)
    local device_state_to_string = {
        [0] = "Unknown",
        [10] = "Unmanaged",
        [20] = "Unavailable",
        [30] = "Disconnected",
        [40] = "Prepare",
        [50] = "Config",
        [60] = "Need Auth",
        [70] = "IP Config",
        [80] = "IP Check",
        [90] = "Secondaries",
        [100] = "Activated",
        [110] = "Deactivated",
        [120] = "Failed",
    }

    return device_state_to_string[state]
end

--- Convert a NetworkManager device type integer to a human-readable string.
-- @tparam integer dtype DeviceType enum value (1 = Ethernet, 2 = WiFi)
-- @treturn string Human-readable device type, or `"Unknown"` if unrecognised
-- @see network.device_type_to_string
function network.device_type_to_string(dtype)
    local device_type_to_string = {
        [1] = "Ethernet",
        [2] = "WiFi",
    }
    return device_type_to_string[dtype] or "Unknown"
end

--- @treturn string|nil Interface name (e.g. `"wlan0"`, `"eth0"`)
function device:get_interface()
    if self._private.device_proxy then
        return self._private.device_proxy.Interface
    end
end

--- @treturn integer DeviceType enum value (1 = Ethernet, 2 = WiFi)
function device:get_type()
    if self._private.device_proxy then
        return self._private.device_proxy.DeviceType
    end
end

--- @treturn string Human-readable device type
function device:get_type_string()
    return network.device_type_to_string(self:get_type())
end

--- @treturn integer DeviceState enum value (10..120)
function device:get_state()
    if self._private.device_proxy then
        return self._private.device_proxy.State
    end
end

--- @treturn string Human-readable device state
function device:get_state_string()
    return network.device_state_to_string(self:get_state())
end

--- @treturn string|nil MAC address (e.g. `"AA:BB:CC:DD:EE:FF"`)
function device:get_hw_address()
    if self._private.device_proxy then
        return self._private.device_proxy.HwAddress
    end
end

--- @treturn string|nil CIDR-style IPv4 address (e.g. `"192.168.1.42/24"`)
function device:get_ip4_address()
    if self._private.ip4_config_proxy then
        local addrs = self._private.ip4_config_proxy.AddressData
        if addrs and #addrs > 0 then
            return addrs[1].address .. "/" .. addrs[1].prefix
        end
    end
end

--- @treturn string|nil D-Bus path of the active connection
function device:get_active_connection()
    if self._private.device_proxy then
        return self._private.device_proxy.ActiveConnection
    end
end

--- @treturn table Wireless access-point objects keyed by D-Bus path
function device:get_access_points()
    if self._private.wireless_proxy then
        return self.access_points
    end
end

--- @tparam string path D-Bus path of the access point
--- @return access-point object or nil
function device:get_access_point(path)
    if self._private.wireless_proxy and self.access_points then
        return self.access_points[path]
    end
end

--- @treturn access-point|nil Currently-active access point, or nil if not connected
function device:get_active_access_point()
    if self._private.wireless_proxy then
        return self:get_access_point(
            self._private.wireless_proxy.ActiveAccessPoint
        )
    end
end

--- Trigger a WiFi scan on this device. No-op on non-wireless devices.
function device:request_scan()
    if self._private.wireless_proxy then
        self._private.wireless_proxy:RequestScanAsync(nil, {}, {})
    end
end

--- Convert NetworkManager security flag bitfields to a short human label.
-- Maps combinations of `(flags, wpa_flags, rsn_flags)` to security
-- keywords like "WEP", "WPA1", "WPA2", "802.1X".
-- @tparam integer flags NM_802_11_AP_SEC flags (privacy bit)
-- @tparam integer wpa_flags NM_802_11_AP_SEC wpa_flags
-- @tparam integer rsn_flags NM_802_11_AP_SEC rsn_flags
-- @treturn string Concatenated security keywords (trimmed)
local function flags_to_security(flags, wpa_flags, rsn_flags)
    local str = ""
    if flags == 1 and wpa_flags == 0 and rsn_flags == 0 then
        str = str .. " WEP"
    end
    if wpa_flags ~= 0 then
        str = str .. " WPA1"
    end
    if not rsn_flags ~= 0 then
        str = str .. " WPA2"
    end
    if wpa_flags == 512 or rsn_flags == 512 then
        str = str .. " 802.1X"
    end

    return (str:gsub("^%s", ""))
end

--- Generate a random UUIDv4 string.
-- Uses the standard "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx" template
-- with `math.random` for hex digits. Not cryptographically secure —
-- suitable for NetworkManager connection identifiers only.
-- @treturn string A 36-character UUIDv4
local function generate_uuid()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    local uuid = string.gsub(template, "[xy]", function(c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format("%x", v)
    end)
    return uuid
end

--- Trim leading and trailing whitespace from a string.
-- @tparam string str Input string
-- @treturn string Trimmed string
local function trim_string(str)
    return str:gsub("^%s*(.-)%s*$", "%1")
end

--- Build a NetworkManager connection profile dict for an access point.
-- Assembles a settings dict (wireless + wireless-security sections)
-- ready to pass to `client:add_connection`. Used by the UI's
-- "connect to network" action.
-- @tparam access_point ap The access point to build a profile for
-- @tparam string|nil password WPA passphrase (or nil for open networks)
-- @tparam boolean auto_connect Whether to mark the connection as autoconnect
-- @treturn table A settings dict consumable by `AddConnection` D-Bus method
local function create_ap_profile(ap, password, auto_connect)
    local s_con = {
        ["uuid"] = lgi.GLib.Variant("s", generate_uuid()),
        ["id"] = lgi.GLib.Variant("s", ap:get_ssid()),
        ["type"] = lgi.GLib.Variant("s", "802-11-wireless"),
        ["autoconnect"] = lgi.GLib.Variant("b", auto_connect),
    }

    local s_ip4 = {
        ["method"] = lgi.GLib.Variant("s", "auto"),
    }

    local s_ip6 = {
        ["method"] = lgi.GLib.Variant("s", "auto"),
    }

    local s_wifi = {
        ["mode"] = lgi.GLib.Variant("s", "infrastructure"),
    }

    local s_wsec = {}
    if ap:get_security() ~= "" then
        if ap:get_security():match("WPA") ~= nil then
            s_wsec["key-mgmt"] = lgi.GLib.Variant("s", "wpa-psk")
            s_wsec["auth-alg"] = lgi.GLib.Variant("s", "open")
            s_wsec["psk"] = lgi.GLib.Variant("s", trim_string(password))
        else
            s_wsec["key-mgmt"] = lgi.GLib.Variant("s", "None")
            s_wsec["wep-key-type"] =
                lgi.GLib.Variant("s", NM.WepKeyType.PASSPHRASE)
            s_wsec["wep-key0"] = lgi.GLib.Variant("s", trim_string(password))
        end
    end

    return {
        ["connection"] = s_con,
        ["ipv4"] = s_ip4,
        ["ipv6"] = s_ip6,
        ["802-11-wireless"] = s_wifi,
        ["802-11-wireless-security"] = s_wsec,
    }
end

--- Build a `connection` object wrapping the NM.Settings.Connection D-Bus proxy.
-- @tparam string path D-Bus object path of the connection
-- @treturn connection|nil The wrapped object, or nil if path is empty
local function create_connection_object(path)
    if not path or path == "/" then
        return
    end
    local connection_object = gobject({})
    gtable.crush(connection_object, connection, true)
    connection_object._private = {}
    connection_object._private.connection_proxy = dbus_proxy.Proxy:new({
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.NetworkManager.Settings.Connection",
        path = path,
    })

    return connection_object
end

--- Build an `access_point` object wrapping the NM.AccessPoint D-Bus proxy.
-- @tparam string path D-Bus object path of the access point
-- @treturn access_point|nil The wrapped object, or nil if path is empty
local function create_access_point_object(path)
    if not path or path == "/" then
        return
    end
    local access_point_object = gobject({})
    gtable.crush(access_point_object, access_point, true)
    access_point_object._private = {}
    access_point_object._private.access_point_proxy = dbus_proxy.Proxy:new({
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.NetworkManager.AccessPoint",
        path = path,
    })

    return access_point_object
end

--- @treturn integer|nil NM global state (see `network.NMState`)
--- @treturn integer|nil NM global state (see `network.NMState`)
function client:get_state()
    if not self._private.client_proxy then
        return
    end
    return self._private.client_proxy.State
end

--- @treturn boolean|nil Whether the system has networking enabled at all
function client:get_networking_enabled()
    if not self._private.client_proxy then
        return
    end
    return self._private.client_proxy.NetworkingEnabled
end

--- Toggle the global networking on/off switch.
-- @tparam boolean state
function client:enable(state)
    if not self._private.client_proxy then
        return
    end
    if self._private.client_proxy.EnableAsync then
        self._private.client_proxy:EnableAsync(function() end, {}, state)
    end
end

--- @treturn boolean `false` if no proxy (D-Bus unavailable), else the live state
function client:get_wireless_enabled()
    if not self._private.client_proxy then
        return false
    end
    return self._private.client_proxy.WirelessEnabled
end

--- Toggle wireless on/off. Also enables networking if it's currently off.
-- @tparam boolean state
function client:set_wireless_enabled(state)
    if not self._private.client_proxy then
        return
    end
    if state == true and self:get_networking_enabled() ~= true then
        self:enable(true)
    end

    if self._private.client_proxy.SetAsync then
        self._private.client_proxy:SetAsync(
            nil,
            {},
            self._private.client_proxy.interface,
            "WirelessEnabled",
            lgi.GLib.Variant("b", state)
        )
        self._private.client_proxy.WirelessEnabled = {
            signature = "b",
            value = state,
        }
    end
end

--- @treturn table All configured connections keyed by D-Bus path
function client:get_connections()
    return self.connections
end

--- @tparam string path
--- @return connection object or nil
function client:get_connection(path)
    return self.connections[path]
end

--- Trigger AddAndActivateConnection for a wireless access point.
-- Builds a settings dict from `ap` (via `create_ap_profile`) and
-- activates it asynchronously. If the AP is already known to NM
-- (has a saved connection path), that connection is reused.
-- @tparam access_point ap The AP to connect to
-- @tparam string|nil password WPA passphrase, or nil for open networks
-- @tparam boolean auto_connect Whether the saved connection should auto-connect
-- @return boolean success whether the activation call was dispatched
function client:connect_access_point(ap, password, auto_connect)
    if not ap or not self._private.client_proxy then
        return
    end
    password = password or ""
    auto_connect = auto_connect or true

    local profile = create_ap_profile(ap, password, auto_connect)

    local ap_connections = {}
    for _, con in pairs(self.connections) do
        if
            con:get_filename()
            and string.find(con:get_filename(), ap:get_ssid())
        then
            table.insert(ap_connections, con)
        end
    end

    if #ap_connections == 0 then
        self._private.client_proxy:AddAndActivateConnectionAsync(
            nil,
            {},
            profile,
            self.wireless._private.device_proxy.object_path,
            ap._private.access_point_proxy.object_path
        )
    else
        ap_connections[1]._private.connection_proxy:UpdateAsync(
            nil,
            {},
            profile
        )
        self._private.client_proxy:ActivateConnectionAsync(
            nil,
            {},
            ap_connections[1]._private.connection_proxy.object_path,
            self.wireless._private.device_proxy.object_path,
            ap._private.access_point_proxy.object_path
        )
    end
end

--- Deactivate the wireless device's active connection.
-- No-op if the client proxy is unavailable.
function client:disconnect_active_access_point()
    if not self._private.client_proxy then
        return
    end
    self._private.client_proxy:DeactivateConnectionAsync(
        nil,
        {},
        self.wireless._private.device_proxy.ActiveConnection
    )
end

--- Deactivate a specific device's active connection.
-- @tparam device dev The device whose active connection should drop
function client:disconnect_access_point(dev)
    if not self._private.client_proxy then
        return
    end
    if dev and dev._private.device_proxy then
        self._private.client_proxy:DeactivateConnectionAsync(
            nil,
            {},
            dev._private.device_proxy.ActiveConnection
        )
    end
end

--- @treturn string Path of the connection's settings file on disk
function connection:get_filename()
    return self._private.connection_proxy.Filename
end

--- @treturn string D-Bus object path of the connection
function connection:get_path()
    return self._private.connection_proxy.object_path
end

--- @treturn string|nil MAC address (e.g. `"AA:BB:CC:DD:EE:FF"`)
function wireless:get_hw_address()
    if self._private.device_proxy then
        return self._private.device_proxy.HwAddress
    end
end

--- @treturn integer DeviceState enum value
function wireless:get_state()
    if self._private.device_proxy then
        return self._private.device_proxy.State
    end
end

--- @treturn integer Bitrate in kbit/s
function wireless:get_bitrate()
    if self._private.wireless_proxy then
        return self._private.wireless_proxy.Bitrate
    end
end

--- @treturn table Wireless access-point objects keyed by D-Bus path
function wireless:get_access_points()
    return self.access_points
end

--- @tparam string path D-Bus path of the access point
--- @treturn access-point|nil The matching access point, or nil
function wireless:get_access_point(path)
    return self.access_points[path]
end

--- @treturn access-point|nil Currently-active access point, or nil
function wireless:get_active_access_point()
    if not self._private.wireless_proxy then
        return
    end
    return self:get_access_point(self._private.wireless_proxy.ActiveAccessPoint)
end

-- Trigger a WiFi scan on this wireless device. No-op if no proxy.
function wireless:request_scan()
    if self._private.wireless_proxy then
        self._private.wireless_proxy:RequestScanAsync(nil, {}, {})
    end
end

--- @treturn string Network SSID (decoded from raw bytes via NM utils)
function access_point:get_ssid()
    return NM.utils_ssid_to_utf8(self._private.access_point_proxy.Ssid)
end

--- @treturn string MAC address of the AP's BSS
function access_point:get_hw_address()
    return self._private.access_point_proxy.HwAddress
end

--- @treturn string Human-readable security description (e.g. "WPA2")
function access_point:get_security()
    return flags_to_security(
        self._private.access_point_proxy.Flags,
        self._private.access_point_proxy.WpaFlags,
        self._private.access_point_proxy.RsnFlags
    )
end

--- @treturn integer Signal strength (0..100)
function access_point:get_strength()
    return self._private.access_point_proxy.Strength
end

--- @treturn integer|nil Frequency in MHz
function access_point:get_frequency()
    if self._private.access_point_proxy then
        return self._private.access_point_proxy.Frequency
    end
end

--- @treturn string Frequency band: "2.4 GHz", "5 GHz", "6 GHz", or "Unknown"
function access_point:get_frequency_band()
    local freq = self:get_frequency()
    if not freq then
        return "Unknown"
    end
    if freq < 3000 then
        return "2.4 GHz"
    elseif freq < 60000 then
        return "5 GHz"
    else
        return "6 GHz"
    end
end

--- @treturn integer|nil Channel number derived from frequency
function access_point:get_channel()
    local freq = self:get_frequency()
    if not freq then
        return nil
    end
    -- 2.4 GHz channels (2412-2484 MHz)
    if freq >= 2412 and freq <= 2484 then
        return (freq - 2407) / 5
    -- 5 GHz channels (5160-5825 MHz)
    elseif freq >= 5160 and freq <= 5825 then
        return (freq - 5000) / 5
    end
    return math.floor(freq / 5) - 400 -- fallback approximation
end

--- @treturn integer|nil Maximum bitrate in kbit/s
function access_point:get_max_bitrate()
    if self._private.access_point_proxy then
        return self._private.access_point_proxy.MaxBitrate
    end
end

--- @treturn string|nil Network mode: "Infrastructure", "Ad-Hoc", or "Unknown"
function access_point:get_mode()
    if self._private.access_point_proxy then
        local mode = self._private.access_point_proxy.Mode
        if mode == 2 then
            return "Infrastructure"
        elseif mode == 1 then
            return "Ad-Hoc"
        else
            return "Unknown"
        end
    end
end

--- @treturn integer|nil Last-seen timestamp (Unix epoch seconds)
function access_point:get_last_seen()
    if self._private.access_point_proxy then
        return self._private.access_point_proxy.LastSeen
    end
end

--- @treturn string D-Bus object path of the access point
function access_point:get_path()
    return self._private.access_point_proxy.object_path
end

--- @treturn integer|nil Wired link speed in Mbit/s
function wired:get_speed()
    if self._private.wired_proxy then
        return self._private.wired_proxy.Speed
    end
end

--- @treturn integer|nil Link speed (Mbit/s for wired, kbit/s for wireless)
function device:get_speed()
    if self._private.wired_proxy then
        return self._private.wired_proxy.Speed
    elseif self._private.wireless_proxy then
        return self._private.wireless_proxy.Bitrate
    end
end

--- @treturn string Human-readable link speed, e.g. "100 Mbps" or "300.0 Mbps"
function device:get_speed_string()
    local speed = self:get_speed()
    if not speed then
        return ""
    end
    if self._private.wired_proxy then
        return string.format("%d Mbps", speed)
    else
        return string.format("%.1f Mbps", speed / 1000)
    end
end

--- Construct a fully-wired network service instance.
-- Wires up the NetworkManager D-Bus client, settings, and per-device
-- proxies. Populates `ret.devices`, `ret.wireless`, `ret.wired`,
-- and `ret.connections` from current NM state.
-- @treturn table Service instance with public methods from `client`
local function new()
    local ret = gobject({})
    gtable.crush(ret, client, true)
    ret._private = {}

    ret._private.client_proxy = dbus_proxy.Proxy:new({
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.NetworkManager",
        path = "/org/freedesktop/NetworkManager",
    })

    ret._private.client_properties_proxy = dbus_proxy.Proxy:new({
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.DBus.Properties",
        path = "/org/freedesktop/NetworkManager",
    })

    ret._private.settings_proxy = dbus_proxy.Proxy:new({
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.NetworkManager.Settings",
        path = "/org/freedesktop/NetworkManager/Settings",
    })

    ret._private.settings_properties_proxy = dbus_proxy.Proxy:new({
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.DBus.Properties",
        path = "/org/freedesktop/NetworkManager/Settings",
    })

    ret._private.client_proxy:connect_signal("StateChanged", function(_, state)
        ret:emit_signal("property::state", state)
    end)

    ret._private.client_properties_proxy:connect_signal(
        "PropertiesChanged",
        function(_, _, props)
            if props.NetworkingEnabled ~= nil then
                ret:emit_signal(
                    "property::networking-enabled",
                    props.NetworkingEnabled
                )
            end
            if props.WirelessEnabled ~= nil then
                ret:emit_signal(
                    "property::wireless-enabled",
                    props.WirelessEnabled
                )
            end
        end
    )

    ret.connections = {}
    ret._private.settings_proxy:connect_signal(
        "NewConnection",
        function(_, path)
            local connection_object = create_connection_object(path)
            ret.connections[path] = connection_object
            ret:emit_signal("connection-added", path)
        end
    )

    ret._private.settings_proxy:connect_signal(
        "ConnectionRemoved",
        function(_, path)
            ret.connections[path] = nil
            ret:emit_signal("connection-removed", path)
        end
    )

    local connection_paths = ret._private.settings_proxy:ListConnections()
    for _, connection_path in ipairs(connection_paths) do
        local connection_object = create_connection_object(connection_path)
        ret.connections[connection_path] = connection_object
    end

    ret._private.settings_properties_proxy:connect_signal(
        "PropertiesChanged",
        function(_, _, props)
            if props.Connections ~= nil then
                ret:emit_signal("property::connections", props.Connections)
            end
        end
    )

    ret.wired = gobject({})
    gtable.crush(ret.wired, wired, true)
    ret.wired._private = {}

    ret.wireless = gobject({})
    gtable.crush(ret.wireless, wireless, true)
    ret.wireless._private = {}

    ret.devices = {}
    ret.wireless_devices = {}
    ret.wired_devices = {}

    local device_paths = ret._private.client_proxy:GetDevices()
    for _, device_path in ipairs(device_paths) do
        local device_proxy = dbus_proxy.Proxy:new({
            bus = dbus_proxy.Bus.SYSTEM,
            name = "org.freedesktop.NetworkManager",
            interface = "org.freedesktop.NetworkManager.Device",
            path = device_path,
        })

        if device_proxy then
            local device_obj = gobject({})
            gtable.crush(device_obj, device, true)
            device_obj._private = {}
            device_obj._private.device_proxy = device_proxy

            if device_proxy.DeviceType == network.DeviceType.ETHERNET then
                device_obj._private.wired_proxy = dbus_proxy.Proxy:new({
                    bus = dbus_proxy.Bus.SYSTEM,
                    name = "org.freedesktop.NetworkManager",
                    interface = "org.freedesktop.NetworkManager.Device.Wired",
                    path = device_path,
                })

                if device_proxy.ActiveConnection then
                    device_obj._private.ip4_config_proxy =
                        dbus_proxy.Proxy:new({
                            bus = dbus_proxy.Bus.SYSTEM,
                            name = "org.freedesktop.NetworkManager",
                            interface = "org.freedesktop.NetworkManager.IP4Config",
                            path = device_proxy.Ip4Config or "/",
                        })
                end

                table.insert(ret.devices, device_obj)
                table.insert(ret.wired_devices, device_obj)

                if not ret.wired._private.device_proxy then
                    ret.wired._private.device_proxy = device_proxy
                    ret.wired._private.wired_proxy =
                        device_obj._private.wired_proxy
                end

                device_proxy:connect_signal(
                    "StateChanged",
                    function(_, new_state, old_state, reason)
                        device_obj:emit_signal(
                            "property::state",
                            new_state,
                            old_state,
                            reason
                        )
                        ret:emit_signal("device::state", device_obj, new_state)
                    end
                )
            elseif device_proxy.DeviceType == network.DeviceType.WIFI then
                device_obj._private.wireless_proxy = dbus_proxy.Proxy:new({
                    bus = dbus_proxy.Bus.SYSTEM,
                    name = "org.freedesktop.NetworkManager",
                    interface = "org.freedesktop.NetworkManager.Device.Wireless",
                    path = device_path,
                })

                device_obj._private.properties_proxy = dbus_proxy.Proxy:new({
                    bus = dbus_proxy.Bus.SYSTEM,
                    name = "org.freedesktop.NetworkManager",
                    interface = "org.freedesktop.DBus.Properties",
                    path = device_path,
                })

                if device_proxy.ActiveConnection then
                    device_obj._private.ip4_config_proxy =
                        dbus_proxy.Proxy:new({
                            bus = dbus_proxy.Bus.SYSTEM,
                            name = "org.freedesktop.NetworkManager",
                            interface = "org.freedesktop.NetworkManager.IP4Config",
                            path = device_proxy.Ip4Config or "/",
                        })
                end

                device_obj.access_points = {}

                device_obj._private.wireless_proxy:connect_signal(
                    "AccessPointAdded",
                    function(_, ap_path)
                        local access_point_object =
                            create_access_point_object(ap_path)
                        device_obj.access_points[ap_path] = access_point_object
                        device_obj:emit_signal("access-point-added", ap_path)
                        device_obj:emit_signal("property::access-points")
                    end
                )

                device_obj._private.wireless_proxy:connect_signal(
                    "AccessPointRemoved",
                    function(_, ap_path)
                        device_obj.access_points[ap_path] = nil
                        device_obj:emit_signal("access-point-removed", ap_path)
                        device_obj:emit_signal("property::access-points")
                    end
                )

                local ap_paths =
                    device_obj._private.wireless_proxy:GetAccessPoints()
                for _, ap_path in ipairs(ap_paths) do
                    local access_point_object =
                        create_access_point_object(ap_path)
                    if access_point_object then
                        device_obj.access_points[ap_path] = access_point_object
                    end
                end

                device_obj._private.properties_proxy:connect_signal(
                    "PropertiesChanged",
                    function(_, _, props)
                        if props.AccessPoints ~= nil then
                            device_obj:emit_signal("property::access-points")
                        end
                        if props.ActiveAccessPoint ~= nil then
                            device_obj:emit_signal(
                                "property::active-access-point",
                                props.ActiveAccessPoint
                            )
                        end
                    end
                )

                table.insert(ret.devices, device_obj)
                table.insert(ret.wireless_devices, device_obj)

                if not ret.wireless._private.device_proxy then
                    ret.wireless._private.device_proxy = device_proxy
                    ret.wireless._private.wireless_proxy =
                        device_obj._private.wireless_proxy
                    ret.wireless._private.properties_proxy =
                        device_obj._private.properties_proxy
                end

                device_proxy:connect_signal(
                    "StateChanged",
                    function(_, new_state, old_state, reason)
                        device_obj:emit_signal(
                            "property::state",
                            new_state,
                            old_state,
                            reason
                        )
                        ret:emit_signal("device::state", device_obj, new_state)
                    end
                )
            end
        end
    end

    if ret.wired._private.device_proxy then
        ret.wired._private.device_proxy:connect_signal(
            "StateChanged",
            function(_, new_state, old_state, reason)
                ret.wired:emit_signal(
                    "property::state",
                    new_state,
                    old_state,
                    reason
                )
            end
        )
    end

    if ret.wireless._private.device_proxy then
        ret.wireless._private.device_proxy:connect_signal(
            "StateChanged",
            function(_, new_state, old_state, reason)
                ret.wireless:emit_signal(
                    "property::state",
                    new_state,
                    old_state,
                    reason
                )
            end
        )
    end

    ret.wireless.access_points = {}
    if ret.wireless._private.wireless_proxy then
        ret.wireless._private.wireless_proxy:connect_signal(
            "AccessPointAdded",
            function(_, path)
                local access_point_object = create_access_point_object(path)
                ret.wireless.access_points[path] = access_point_object
                ret.wireless:emit_signal("access-point-added", path)
            end
        )

        ret.wireless._private.wireless_proxy:connect_signal(
            "AccessPointRemoved",
            function(_, path)
                ret.wireless.access_points[path] = nil
                ret.wireless:emit_signal("access-point-removed", path)
            end
        )

        local access_point_paths =
            ret.wireless._private.wireless_proxy:GetAccessPoints()
        for _, access_point_path in ipairs(access_point_paths) do
            local access_point_object =
                create_access_point_object(access_point_path)
            if access_point_object then
                ret.wireless.access_points[access_point_path] =
                    access_point_object
            end
        end
    end

    if ret.wireless._private.properties_proxy then
        ret.wireless._private.properties_proxy:connect_signal(
            "PropertiesChanged",
            function(_, _, props)
                if props.AccessPoints ~= nil then
                    ret.wireless:emit_signal(
                        "property::access-points",
                        props.AccessPoints
                    )
                end
                if props.ActiveAccessPoint ~= nil then
                    ret.wireless:emit_signal(
                        "property::active-access-point",
                        props.ActiveAccessPoint
                    )
                end
            end
        )
    end

    return ret
end

--- Construct a fallback no-D-Bus service instance.
-- Used when NetworkManager lgi binding fails to load. All methods
-- short-circuit gracefully (returning nil/empty). Lets the UI
-- render the popup without crashing when D-Bus is unavailable.
-- @treturn table Empty service instance with the same public surface
local function create_fallback()
    local ret = gobject({})
    gtable.crush(ret, client, true)
    ret._private = {}
    ret.devices = {}
    ret.wireless_devices = {}
    ret.wired_devices = {}
    ret.connections = {}
    ret.wired = gobject({})
    ret.wired._private = {}
    ret.wireless = gobject({})
    gtable.crush(ret.wireless, wireless, true)
    ret.wireless._private = {}
    ret.wireless.access_points = {}
    return ret
end

local instance = nil
--- Singleton accessor: returns (and lazily constructs) the network service.
-- Caches the result in a closure so subsequent calls return the same
-- instance. Falls back to a stub if the NM lgi binding is missing.
-- @treturn table The cached network service instance
local function get_default()
    if not instance then
        if not _NM_status or not NM then
            instance = create_fallback()
        else
            local ok, result = pcall(new)
            instance = ok and result or create_fallback()
        end
    end
    return instance
end

return setmetatable({
    get_default = get_default,
}, {
    __index = network,
})
