--- Connection module for the network service.
-- Defines the `connection` method table and the factory function for
-- creating connection objects from D-Bus paths.
-- @module service.network.connection

local dbus_proxy = require("lib.dbus_proxy")
local gobject = require("gears.object")
local gtable = require("gears.table")

local connection = {}

-- ---------------------------------------------------------------------------
-- Connection methods (crushed onto individual connection gobject instances)
-- ---------------------------------------------------------------------------

--- @treturn string Path of the connection's settings file on disk
function connection:get_filename()
    return self._private.connection_proxy.Filename
end

--- @treturn string D-Bus object path of the connection
function connection:get_path()
    return self._private.connection_proxy.object_path
end

-- ---------------------------------------------------------------------------
-- Factory function
-- ---------------------------------------------------------------------------

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

return {
    connection = connection,
    create_connection_object = create_connection_object,
}
