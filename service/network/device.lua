--- Device, Wired, and Wireless method tables for the network service.
-- These method tables are crushed onto gobject instances during
-- initialization in `new()`. They are not constructors — they define
-- the behaviour of per-device and aggregate wireless/wired wrappers.
-- @module service.network.device

local constants = require("service.network.constants")

local device = {}
local wired = {}
local wireless = {}

-- ---------------------------------------------------------------------------
-- device methods (crushed onto individual device objects)
-- ---------------------------------------------------------------------------

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
    return constants.device_type_to_string(self:get_type())
end

--- @treturn integer DeviceState enum value (10..120)
function device:get_state()
    if self._private.device_proxy then
        return self._private.device_proxy.State
    end
end

--- @treturn string Human-readable device state
function device:get_state_string()
    return constants.device_state_to_string(self:get_state())
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

-- ---------------------------------------------------------------------------
-- wired methods (crushed onto `ret.wired` aggregate object)
-- ---------------------------------------------------------------------------

--- @treturn integer|nil Wired link speed in Mbit/s
function wired:get_speed()
    if self._private.wired_proxy then
        return self._private.wired_proxy.Speed
    end
end

-- ---------------------------------------------------------------------------
-- wireless methods (crushed onto `ret.wireless` aggregate object)
-- ---------------------------------------------------------------------------

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

--- Trigger a WiFi scan on this wireless device. No-op if no proxy.
function wireless:request_scan()
    if self._private.wireless_proxy then
        self._private.wireless_proxy:RequestScanAsync(nil, {}, {})
    end
end

return {
    device = device,
    wired = wired,
    wireless = wireless,
}
