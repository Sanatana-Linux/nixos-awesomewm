--- Client (main instance) method table for the network service.
-- Defines the public API methods that are crushed onto the singleton
-- instance created by `new()`. These methods interact with the
-- NetworkManager D-Bus client proxy.
-- @module service.network.client

local lgi = require("lgi")

local dbus_proxy = require("lib.dbus_proxy")
local ap_mod = require("service.network.access_point")

local client = {}

-- ---------------------------------------------------------------------------
-- Client methods (crushed onto the singleton instance)
-- ---------------------------------------------------------------------------

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

    local profile = ap_mod.create_ap_profile(ap, password, auto_connect)

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

return {
    client = client,
}
