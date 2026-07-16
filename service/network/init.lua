--- NetworkManager integration service.
-- Watches the NetworkManager D-Bus service for state changes and exposes a
-- Lua-side object model (clients, devices, connections, access points) that
-- the UI layer can iterate. When NetworkManager is unavailable (no DBus
-- service, missing permissions, headless boot), the service still loads but
-- exposes empty collections — UI code can guard with `if network.NM then …`.
--
-- This module is the orchestration entry point. It imports method tables and
-- factory functions from focused submodules and wires them into the D-Bus
-- proxy infrastructure in `new()`.
-- @module service.network

local gobject = require("gears.object")
local gtable = require("gears.table")
local dbus_proxy = require("lib.dbus_proxy")

local constants = require("service.network.constants")
local device_mod = require("service.network.device")
local ap_mod = require("service.network.access_point")
local conn_mod = require("service.network.connection")
local client_mod = require("service.network.client")

-- Re-export NM so callers can test availability
local NM = constants.NM
local network = {
    NM = NM,
    NMState = constants.NMState,
    DeviceType = constants.DeviceType,
    DeviceState = constants.DeviceState,
    device_state_to_string = constants.device_state_to_string,
    device_type_to_string = constants.device_type_to_string,
}

-- Method tables for crushing onto gobject instances
local device = device_mod.device
local wired = device_mod.wired
local wireless = device_mod.wireless
local access_point = ap_mod.access_point
local connection = conn_mod.connection
local client = client_mod.client

-- Factory functions
local create_connection_object = conn_mod.create_connection_object
local create_access_point_object = ap_mod.create_access_point_object

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

    -- Client-level signal handlers
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

    -- Connections
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

    -- Wired / Wireless aggregate wrappers
    ret.wired = gobject({})
    gtable.crush(ret.wired, wired, true)
    ret.wired._private = {}

    ret.wireless = gobject({})
    gtable.crush(ret.wireless, wireless, true)
    ret.wireless._private = {}

    ret.devices = {}
    ret.wireless_devices = {}
    ret.wired_devices = {}

    -- Enumerate existing devices
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
                -- Wired device
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
                -- Wireless device
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

    -- Wired aggregate state signal
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

    -- Wireless aggregate state signal
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

    -- Wireless aggregate access-point signals
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

    -- Wireless aggregate properties signal
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
