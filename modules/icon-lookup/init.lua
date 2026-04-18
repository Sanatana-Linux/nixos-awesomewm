-- modules/icon-lookup/init.lua
-- Centralized icon lookup module for consistent icon resolution across all UI components
-- Supports system icon themes, client icons, desktop app info, and fallbacks

local menubar = require("menubar")
local beautiful = require("beautiful")
local gears = require("gears")
local lgi = require("lgi")
local Gio = lgi.Gio

local icon_lookup = {}

-- Icon cache to avoid repeated expensive lookups
local icon_cache = {}

-- Default icon theme (can be overridden by beautiful.icon_theme)
local DEFAULT_ICON_THEME = "Honor-grey-dark"

-- Fallback icon path
local FALLBACK_ICON = "/home/tlh/.config/awesome/themes/kailash/icons/desktop/fallback_icon.svg"

-- Enhanced application class to icon name mappings
-- Based on available icons in common icon themes
local CLASS_MAPPINGS = {
    -- Browsers
    ["firefox"] = "firefox",
    ["firefox-esr"] = "firefox-esr",
    ["chromium"] = "chromium",
    ["chromium-browser"] = "chromium",
    ["google-chrome"] = "google-chrome",
    ["chrome"] = "google-chrome",
    ["brave"] = "brave-browser",
    ["opera"] = "opera",
    ["vivaldi"] = "vivaldi",
    
    -- Terminals
    ["alacritty"] = "terminal",
    ["kitty"] = "terminal", 
    ["gnome-terminal"] = "gnome-terminal",
    ["xfce4-terminal"] = "xfce4-terminal",
    ["lxterminal"] = "lxterminal",
    ["qterminal"] = "qterminal",
    ["terminator"] = "terminal",
    ["konsole"] = "terminal",
    ["tilix"] = "tilix",
    ["guake"] = "guake",
    
    -- File managers
    ["nautilus"] = "org.gnome.files",
    ["thunar"] = "system-file-manager", 
    ["nemo"] = "file-manager",
    ["pcmanfm"] = "file-manager",
    ["dolphin"] = "file-manager",
    ["ranger"] = "file-manager",
    
    -- Code editors and IDEs
    ["code"] = "code",
    ["code-oss"] = "code",
    ["vscode"] = "code",
    ["atom"] = "atom",
    ["sublime_text"] = "sublime-text",
    ["vim"] = "vim",
    ["emacs"] = "emacs",
    ["gedit"] = "text-editor",
    ["kate"] = "kate",
    
    -- Communication
    ["discord"] = "discord",
    ["telegram-desktop"] = "telegram",
    ["telegram"] = "telegram", 
    ["slack"] = "slack",
    ["teams"] = "teams",
    ["zoom"] = "zoom",
    ["signal"] = "signal-desktop",
    
    -- Media
    ["vlc"] = "vlc",
    ["mpv"] = "mpv",
    ["rhythmbox"] = "rhythmbox",
    ["spotify"] = "spotify",
    ["audacity"] = "audacity",
    
    -- Graphics
    ["gimp"] = "gimp",
    ["inkscape"] = "inkscape", 
    ["blender"] = "blender",
    ["krita"] = "krita",
    
    -- Office
    ["libreoffice"] = "libreoffice",
    ["libreoffice-writer"] = "libreoffice-writer",
    ["libreoffice-calc"] = "libreoffice-calc",
    ["libreoffice-impress"] = "libreoffice-impress",
    
    -- System tools
    ["gnome-system-monitor"] = "system-monitor",
    ["htop"] = "system-monitor",
    ["synaptic"] = "synaptic",
}

-- Get the configured icon theme
local function get_icon_theme()
    return beautiful.icon_theme or DEFAULT_ICON_THEME
end

-- Cache key generator for apps
local function get_app_cache_key(app)
    if not app then return nil end
    local app_id = app:get_id()
    local app_name = app:get_name()
    return string.format("app:%s:%s", app_id or "nil", app_name or "nil")
end

-- Cache key generator for clients  
local function get_client_cache_key(client)
    if not client then return nil end
    local class_name = client.class or "nil"
    local instance_name = client.instance or "nil"
    return string.format("client:%s:%s", class_name, instance_name)
end

-- Generic cached lookup function
local function get_cached_icon(cache_key, lookup_func)
    if not cache_key then return lookup_func() end
    
    if not icon_cache[cache_key] then
        icon_cache[cache_key] = lookup_func()
    end
    
    return icon_cache[cache_key]
end

-- Look up an icon in the system theme
local function lookup_system_icon(icon_name)
	if not icon_name or icon_name == "" then
		return nil
	end

	local icon_path = menubar.utils.lookup_icon(icon_name)

	-- menubar.utils.lookup_icon may return empty string instead of nil
	if icon_path and icon_path ~= "" then
		return icon_path
	end

	return nil
end

-- Get icon name from desktop file using application ID or class name
local function get_desktop_icon_name(app_id, class_name)
    if not app_id and not class_name then
        return nil
    end
    
    -- Try to get icon from desktop file
    local success, result = pcall(function()
        local desktop_names = {}
        
        if app_id then
            table.insert(desktop_names, app_id)
            table.insert(desktop_names, app_id .. ".desktop")
        end
        
        if class_name then
            table.insert(desktop_names, string.lower(class_name))
            table.insert(desktop_names, string.lower(class_name) .. ".desktop")
        end
        
        for _, name in ipairs(desktop_names) do
            if name ~= "" and name ~= ".desktop" then
                local desktop_info = Gio.DesktopAppInfo.new(name)
                if desktop_info then
                    local icon_str = desktop_info:get_string("Icon")
                    if icon_str and icon_str ~= "" then
                        return icon_str
                    end
                end
            end
        end
        
        return nil
    end)
    
    return success and result or nil
end

-- Get icon for a client window
function icon_lookup.get_client_icon(client)
    if not client then
        return FALLBACK_ICON
    end
    
    local cache_key = get_client_cache_key(client)
    
    return get_cached_icon(cache_key, function()
        local class_name = client.class
        local instance_name = client.instance
        
        -- Try multiple icon resolution strategies
        local icon_candidates = {}
        
        -- 1. Try desktop file lookup
        local desktop_icon = get_desktop_icon_name(nil, class_name)
        if desktop_icon then
            table.insert(icon_candidates, desktop_icon)
        end
        
        -- 2. Try direct class name lookup
        if class_name then
            table.insert(icon_candidates, string.lower(class_name))
        end
        
        -- 3. Try instance name lookup
        if instance_name then
            table.insert(icon_candidates, string.lower(instance_name))
        end
        
        -- 4. Try class mappings
        if class_name then
            local mapped_name = CLASS_MAPPINGS[string.lower(class_name)]
            if mapped_name then
                table.insert(icon_candidates, mapped_name)
            end
        end
        
        -- 5. Try some generic patterns
        table.insert(icon_candidates, "application-x-executable")
        table.insert(icon_candidates, "applications-system")
        
        -- Look up each candidate in the system theme
        for _, candidate in ipairs(icon_candidates) do
            local icon_path = lookup_system_icon(candidate)
            if icon_path and gears.filesystem.file_readable(icon_path) then
                return icon_path
            end
        end
        
        -- Return nil if no system icon found (caller can decide on fallback)
        return nil
    end)
end

-- Get icon for an application (from launcher/app list)  
function icon_lookup.get_app_icon(app)
    if not app then
        return FALLBACK_ICON
    end
    
    local cache_key = get_app_cache_key(app)
    
    return get_cached_icon(cache_key, function()
        local icon_name = nil
        local icon_path = nil
        
        -- Try to get icon directly from app object
        local icon_status, icon_result = pcall(function()
            return app:get_icon()
        end)
        
        if icon_status and icon_result then
            -- If we have a GIcon object, try to get icon names from it
            local names_status, names = pcall(function()
                return icon_result:get_names()
            end)
            if names_status and names and names[1] then
                icon_name = names[1]
            elseif names_status and names == nil then
                -- ThemedIcon might return nil for get_names, use tostring
                local str_status, icon_str = pcall(function()
                    return tostring(icon_result)
                end)
                if str_status and icon_str then
                    icon_name = icon_str
                end
            end
        end
        
        -- Fallback: try to get icon from desktop entry file
        if not icon_name and Gio.DesktopAppInfo then
            local desktop_status, desktop_info = pcall(function()
                return Gio.DesktopAppInfo.new(app:get_id())
            end)
            if desktop_status and desktop_info then
                local icon_str_status, icon_str = pcall(function()
                    return desktop_info:get_string("Icon")
                end)
                if icon_str_status and icon_str and icon_str ~= "" then
                    icon_name = icon_str
                end
            end
        end
        
	-- Final fallback: use app name or executable
	if not icon_name then
		icon_name = string.lower(app:get_name()) or "application-x-executable"
	end

	-- Look up the icon in the system theme
	icon_path = lookup_system_icon(icon_name)

	-- If not found, try common fallbacks
	if not icon_path or icon_path == "" then
		icon_path = lookup_system_icon("application-x-executable")
	end

	if not icon_path or icon_path == "" then
		icon_path = lookup_system_icon("applications-other")
	end

	-- Final fallback to theme's fallback icon
	if not icon_path or icon_path == "" then
		icon_path = FALLBACK_ICON
	end

	return icon_path
end)
end

-- Get fallback icon path
function icon_lookup.get_fallback_icon()
    return FALLBACK_ICON
end

-- Check if a file is readable
function icon_lookup.is_readable(path)
    return path and gears.filesystem.file_readable(path)
end

-- Get current icon theme name
function icon_lookup.get_theme_name()
    return get_icon_theme()
end

-- Clear the icon cache (useful when icon theme changes)
function icon_lookup.clear_cache()
    icon_cache = {}
end

-- Get cache statistics (for debugging)
function icon_lookup.get_cache_stats()
    local count = 0
    for _ in pairs(icon_cache) do
        count = count + 1
    end
    return {
        cached_icons = count,
        theme = get_icon_theme()
    }
end

return icon_lookup