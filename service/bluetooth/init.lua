--- Bluetooth service.
-- Wraps the BlueZ D-Bus interface into two object types:
--   * `adapter` (hci0) — power, discovery, rfkill state
--   * `device` (a paired peripheral) — connect, pair, battery percentage
-- All lgi calls are wrapped in `pcall` (the proxy factory does this
-- automatically). Emits `property::powered` / `property::discovering` /
-- `property::blocked` on the adapter, and `property::connected` /
-- `property::paired` / `property::trusted` / `property::percentage` on
-- each device.
-- @module service.bluetooth

local lgi = require("lgi")
local dbus_proxy = require("lib.dbus_proxy")
local gobject = require("gears.object")
local gtable = require("gears.table")
local awful = require("awful")

local adapter = {}
local device = {}

--- Build a `device` object wrapping the BlueZ Device1 + Battery1 D-Bus proxies.
-- @tparam string path D-Bus object path of the device (e.g. `/org/bluez/hci0/dev_XX_XX_XX_XX_XX_XX`)
-- @treturn device|nil The wrapped device object, or nil if path is empty
local function create_device_object(path)
    if not path or path == "/" then
        return
    end
    local device_object = gobject({})
    gtable.crush(device_object, device, true)
    device_object._private = {}

    device_object._private.device_proxy = dbus_proxy.Proxy:new({
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.bluez",
        interface = "org.bluez.Device1",
        path = path,
    })

    device_object._private.battery_proxy = dbus_proxy.Proxy:new({
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.bluez",
        interface = "org.bluez.Battery1",
        path = path,
    })

    device_object._private.properties_proxy = dbus_proxy.Proxy:new({
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.bluez",
        interface = "org.freedesktop.DBus.Properties",
        path = path,
    })

    device_object._private.properties_proxy:connect_signal(
        "PropertiesChanged",
        function(_, _, props)
            if props.Connected ~= nil then
                device_object:emit_signal(
                    "property::connected",
                    props.Connected
                )
            end
            if props.Paired ~= nil then
                device_object:emit_signal("property::paired", props.Paired)
            end
            if props.Trusted ~= nil then
                device_object:emit_signal("property::trusted", props.Trusted)
            end
            if props.Percentage ~= nil then
                device_object:emit_signal(
                    "property::percentage",
                    props.Percentage
                )
            end
        end
    )

    return device_object
end

--- Turn the adapter radio on or off.
-- @tparam boolean state `true` to power on, `false` to power off
function adapter:set_powered(state)
    if self._private.adapter_proxy.SetAsync then
        self._private.adapter_proxy:SetAsync(
            nil,
            {},
            self._private.adapter_proxy.interface,
            "Powered",
            lgi.GLib.Variant("b", state)
        )
        self._private.adapter_proxy.Powered = {
            signature = "b",
            value = state,
        }
    end
end

--- @treturn boolean Whether the adapter radio is currently powered
function adapter:get_powered()
    return self._private.adapter_proxy.Powered
end

--- Begin scanning for nearby Bluetooth devices. No-op if already discovering.
function adapter:start_discovery()
    if not self._private.adapter_proxy then
        return
    end
    if self._private.adapter_proxy.Discovering ~= true then
        self._private.adapter_proxy:StartDiscoveryAsync(nil, {})
    end
end

--- Stop an in-progress device scan. No-op if not currently discovering.
function adapter:stop_discovery()
    if not self._private.adapter_proxy then
        return
    end
    if self._private.adapter_proxy.Discovering == true then
        self._private.adapter_proxy:StopDiscoveryAsync(nil, {})
    end
end

--- @treturn boolean Whether a device scan is currently in progress
function adapter:get_discovering()
    return self._private.adapter_proxy.Discovering
end

function adapter:get_powered()
    return self._private.adapter_proxy.Powered
end

--- @treturn boolean Whether the adapter is soft-blocked by rfkill
function adapter:is_blocked()
    return self._private.blocked or false
end

--- Run `rfkill unblock bluetooth` and clear the local blocked flag.
-- @tparam function|nil callback Called after the rfkill command returns
function adapter:unblock(callback)
    awful.spawn.easy_async("rfkill unblock bluetooth", function()
        self._private.blocked = false
        self:emit_signal("property::blocked", false)
        if callback then
            callback()
        end
    end)
end

--- @treturn table All known device objects keyed by D-Bus path
function adapter:get_devices()
    return self.devices
end

--- @tparam string path D-Bus object path of the device
--- @treturn device|nil The matching device object, or nil
function adapter:get_device(path)
    return self.devices[path]
end

-- Establish a connection to the device. No-op if already connected.
function device:connect()
    if self._private.device_proxy.Connected ~= true then
        self._private.device_proxy:ConnectAsync(nil, {})
    end
end

-- Drop an active connection. No-op if not connected.
function device:disconnect()
    if self._private.device_proxy.Connected == true then
        self._private.device_proxy:DisconnectAsync(nil, {})
    end
end

-- Initiate pairing. No-op if already paired.
function device:pair()
    if self._private.device_proxy.Paired ~= true then
        self._private.device_proxy:PairAsync(nil, {})
    end
end

-- Cancel an in-progress pairing attempt. No-op if not paired.
function device:cancel_pairing()
    if self._private.device_proxy.Paired == true then
        self._private.device_proxy:CancelPairingAsync(nil, {})
    end
end

--- Mark a device as trusted (auto-reconnect allowed) or untrusted.
-- @tparam boolean trusted `true` to allow auto-reconnect, `false` to forbid
function device:set_trusted(trusted)
    self._private.device_proxy:SetAsync(
        nil,
        {},
        self._private.device_proxy.interface,
        "Trusted",
        lgi.GLib.Variant("b", trusted)
    )
    self._private.device_proxy.Trusted = {
        signature = "b",
        value = trusted,
    }
end

--- @treturn boolean Whether the device is currently connected
function device:get_connected()
    return self._private.device_proxy.Connected
end

--- @treturn boolean Whether the device has completed pairing
function device:get_paired()
    return self._private.device_proxy.Paired
end

--- @treturn boolean Whether the device is trusted (auto-reconnect allowed)
function device:get_trusted()
    return self._private.device_proxy.Trusted
end

--- @treturn string The device's friendly display name
function device:get_name()
    return self._private.device_proxy.Name
end

--- @treturn string BlueZ icon name (e.g. "audio-headset", "input-keyboard")
function device:get_icon()
    return self._private.device_proxy.Icon
end

--- @treturn string Device MAC address (e.g. "AA:BB:CC:DD:EE:FF")
function device:get_address()
    return self._private.device_proxy.Address
end

--- @treturn integer|nil Battery percentage 0..100, or nil if no Battery1 interface
function device:get_percentage()
    return self._private.battery_proxy.Percentage
end

--- @treturn string D-Bus object path of the device
function device:get_path()
    return self._private.device_proxy.object_path
end

--- Construct a fully-wired bluetooth service instance.
-- Sets up the org.bluez ObjectManager proxy, the hci0 adapter proxy,
-- enumerates current devices, and checks rfkill state.
-- @treturn table Service instance with adapter/device methods
local function new()
    local ret = gobject({})
    gtable.crush(ret, adapter, true)
    ret._private = {}

    ret._private.object_manager_proxy = dbus_proxy.Proxy:new({
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.bluez",
        interface = "org.freedesktop.DBus.ObjectManager",
        path = "/",
    })

    if ret._private.object_manager_proxy then
        ret._private.adapter_proxy = dbus_proxy.Proxy:new({
            bus = dbus_proxy.Bus.SYSTEM,
            name = "org.bluez",
            interface = "org.bluez.Adapter1",
            path = "/org/bluez/hci0",
        })

        ret._private.properties_proxy = dbus_proxy.Proxy:new({
            bus = dbus_proxy.Bus.SYSTEM,
            name = "org.bluez",
            interface = "org.freedesktop.DBus.Properties",
            path = "/org/bluez/hci0",
        })

        ret._private.properties_proxy:connect_signal(
            "PropertiesChanged",
            function(_, _, props)
                if props.Powered ~= nil then
                    ret:emit_signal("property::powered", props.Powered)
                end
                if props.Discovering ~= nil then
                    ret:emit_signal("property::discovering", props.Discovering)
                end
            end
        )

        ret.devices = {}
        ret._private.object_manager_proxy:connect_signal(
            "InterfacesAdded",
            function(_, path)
                if
                    path:match(
                        "^/org/bluez/hci0/dev_%w%w_%w%w_%w%w_%w%w_%w%w_%w%w$"
                    )
                then
                    ret.devices[path] = create_device_object(path)
                    ret:emit_signal("device-added", path)
                end
            end
        )

        ret._private.object_manager_proxy:connect_signal(
            "InterfacesRemoved",
            function(_, path)
                if
                    path:match(
                        "^/org/bluez/hci0/dev_%w%w_%w%w_%w%w_%w%w_%w%w_%w%w$"
                    )
                then
                    ret.devices[path] = nil
                    ret:emit_signal("device-removed", path)
                end
            end
        )

        if ret._private.object_manager_proxy.GetManagedObjects then
            local object_paths =
                ret._private.object_manager_proxy:GetManagedObjects()
            for path, _ in pairs(object_paths) do
                if
                    path:match(
                        "^/org/bluez/hci0/dev_%w%w_%w%w_%w%w_%w%w_%w%w_%w%w$"
                    )
                then
                    ret.devices[path] = create_device_object(path)
                end
            end
        end
    end

    awful.spawn.easy_async("rfkill list bluetooth", function(stdout)
        ret._private.blocked = stdout:match("Soft blocked: yes") ~= nil
        ret:emit_signal("property::blocked", ret._private.blocked)
    end)

    return ret
end

local instance = nil
--- Singleton accessor: returns (and lazily constructs) the bluetooth service.
-- @treturn table Cached service instance (same object on every call)
local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return {
    get_default = get_default,
}
