--- Access Point module for the network service.
-- Defines the `access_point` method table, factory function, security
-- flag parsing helpers, and AP connection-profile creation.
-- @module service.network.access_point

local lgi = require("lgi")

local dbus_proxy = require("lib.dbus_proxy")
local gobject = require("gears.object")
local gtable = require("gears.table")
local constants = require("service.network.constants")

local access_point = {}

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

-- ---------------------------------------------------------------------------
-- AccessPoint methods (crushed onto individual AP gobject instances)
-- ---------------------------------------------------------------------------

--- @treturn string Network SSID (decoded from raw bytes via NM utils)
function access_point:get_ssid()
    local NM = constants.NM
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

-- ---------------------------------------------------------------------------
-- Factory functions
-- ---------------------------------------------------------------------------

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

--- Build a NetworkManager connection profile dict for an access point.
-- Assembles a settings dict (wireless + wireless-security sections)
-- ready to pass to `client:add_connection`. Used by the UI's
-- "connect to network" action.
-- @tparam access_point ap The access point to build a profile for
-- @tparam string|nil password WPA passphrase (or nil for open networks)
-- @tparam boolean auto_connect Whether to mark the connection as autoconnect
-- @treturn table A settings dict consumable by `AddConnection` D-Bus method
local function create_ap_profile(ap, password, auto_connect)
    local NM = constants.NM
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

return {
    access_point = access_point,
    create_access_point_object = create_access_point_object,
    create_ap_profile = create_ap_profile,
}
