-- This module provides functionality for retrieving icons based on various criteria
-- such as process ID, icon name, and class.
-- It utilizes the lgi library to interact with the Gtk.IconTheme and Gio.AppInfo modules.

local lgi = require("lgi")
local Gio = lgi.Gio
local Gtk = lgi.require("Gtk", "3.0")
local gobject = require("gears.object")
local gtable = require("gears.table")
local setmetatable = setmetatable
local ipairs = ipairs
local beautiful = require("beautiful")

local dpi = beautiful.xresources.apply_dpi

local icon_theme = { mt = {} }

-- Lookup table for specific application name mappings.
local name_lookup = {
    ["jetbrains-studio"] = "android-studio",
}

-- Retrieves the icon path for the given GIcon object.
-- @param gicon Gio.Icon The GIcon object to retrieve the path for.
-- @return string The icon path or an empty string if not found.
local function get_gicon_path(self, gicon)
    if not gicon then
        return ""
    end

    local icon_info = self.gtk_theme:lookup_by_gicon(gicon, self.icon_size, 0)
    return icon_info and icon_info:get_filename() or ""
end

-- Retrieves the icon path for the given icon name.
-- @param icon_name string The name of the icon to retrieve.
-- @return string The icon path or an empty string if not found.
local function get_icon_path(self, icon_name)
    local icon_info = self.gtk_theme:lookup_icon(icon_name, self.icon_size, 0)
    return icon_info and icon_info:get_filename() or ""
end

-- Retrieves the icon path based on the process ID of the client.
-- @param client table The client object containing information about the application.
-- @param apps table A list of Gio.AppInfo objects representing installed applications.
-- @return string|nil The icon path if found, otherwise nil.
local function get_icon_by_pid_command(self, client, apps)
    local pid = client.pid
    if not pid then
        return nil
    end

    local handle = io.popen(string.format("ps -p %d -o comm=", pid))
    local pid_command = handle:read("*a"):gsub("^%s*(.-)%s*$", "%1")
    handle:close()

    for _, app in ipairs(apps) do
        local executable = app:get_executable()
        if executable and executable:find(pid_command, 1, true) then
            return get_gicon_path(self, app:get_icon())
        end
    end

    return nil
end

-- Retrieves the icon path based on the icon name of the client.
-- @param client table The client object containing information about the application.
-- @param apps table A list of Gio.AppInfo objects representing installed applications.
-- @return string|nil The icon path if found, otherwise nil.
local function get_icon_by_icon_name(self, client, apps)
    local icon_name = client.icon_name and client.icon_name:lower()
    if not icon_name then
        return nil
    end

    for _, app in ipairs(apps) do
        local name = app:get_name():lower()
        if name and name:find(icon_name, 1, true) then
            return get_gicon_path(self, app:get_icon())
        end
    end

    return nil
end

-- Retrieves the icon path based on the class of the client.
-- @param client table The client object containing information about the application.
-- @param apps table A list of Gio.AppInfo objects representing installed applications.
-- @return string|nil The icon path if found, otherwise nil.
local function get_icon_by_class(self, client, apps)
    local class = client.class
        and (name_lookup[client.class] or client.class:lower())
    if not class then
        return nil
    end

    -- Generate variations of the class name to increase matching possibilities.
    local class_1 = class:gsub("[%-]", "")
    local class_2 = class:gsub("[%-]", ".")
    local class_3 = (class:match("(.-)-") or class):match("(.-)%.")
        or class:match("(.-)%s+")
        or class

    local possible_icon_names = { class, class_3, class_2, class_1 }
    for _, app in ipairs(apps) do
        local id = app:get_id():lower()
        for _, possible_icon_name in ipairs(possible_icon_names) do
            if id and id:find(possible_icon_name, 1, true) then
                return get_gicon_path(self, app:get_icon())
            end
        end
    end

    return nil
end

-- Retrieves the icon path for the client based on various criteria.
-- It tries to find an icon based on the process ID, icon name, and class.
-- If no specific icon is found, it falls back to a generic window icon.
-- @param client table The client object containing information about the application.
-- @return string The icon path.
function icon_theme:get_client_icon_path(client)
    local apps = Gio.AppInfo.get_all()

    return get_icon_by_pid_command(self, client, apps)
        or get_icon_by_icon_name(self, client, apps)
        or get_icon_by_class(self, client, apps)
        or client.icon
        or get_icon_path(self, "window")
        or get_icon_path(self, "window-manager")
        or get_icon_path(self, "xfwm4-default")
        or get_icon_path(self, "window_list")
end

-- Chooses an icon from the provided list of icon names.
-- @param icons_names table A list of icon names to choose from.
-- @return string The path of the chosen icon or an empty string if none are found.
function icon_theme:choose_icon(icons_names)
    local icon_info = self.gtk_theme:choose_icon(icons_names, self.icon_size, 0)
    return icon_info and icon_info:get_filename() or ""
end

-- Creates a new instance of the icon_theme module.
-- @param theme_name string Optional. The name of the icon theme to use.
-- @param icon_size number Optional. The desired icon size.
-- @return table A new icon_theme object.
local function new(theme_name, icon_size)
    local ret = gobject({})
    gtable.crush(ret, icon_theme, true)

    ret.name = beautiful.icon_theme or theme_name
    ret.icon_size = dpi(96) or icon_size

    if theme_name then
        ret.gtk_theme = Gtk.IconTheme.new()
        Gtk.IconTheme.set_custom_theme(ret.gtk_theme, theme_name)
    else
        ret.gtk_theme = Gtk.IconTheme.get_default()
    end

    return ret
end

-- Allows creating a new instance of the icon_theme module using the syntax `icon_theme()`.
function icon_theme.mt:__call(...)
    return new(...)
end

return setmetatable(icon_theme, icon_theme.mt)
