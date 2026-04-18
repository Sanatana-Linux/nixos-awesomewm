---@diagnostic disable: undefined-global

--[[
    AwesomeWM Client Management Module

    This module configures client (window) behavior, rules, and focus handling for AwesomeWM.
    It sets up rules for window placement, titlebars, floating behavior, and focus policies.
    Signals are connected to handle client management events, workspace changes, and focus restoration.

    Key Features:
    - Placement and geometry handling for fullscreen, maximized, and transient clients
    - Custom rules for specific applications and window types
    - Sloppy focus (focus follows mouse) implementation
    - Focus restoration after minimizing, closing, or workspace switching
    - Ensures clients are always reachable and properly placed
--]]

-- Import required AwesomeWM libraries
local awful = require("awful")
local rclient = require("ruled.client")
local beautiful = require("beautiful")
local shapes = require("modules.shapes.init")
local dpi = beautiful.xresources.apply_dpi
local capi = { client = client, tag = tag, mouse = mouse }
local awesome = awesome
require("awful.autofocus")
require("configuration.client.better_resize")
require("configuration.client.center_in_parent")
require("configuration.client.restore_clients")

--[[
    Shared placement function:
    Centers the client and ensures it stays on screen.
    Used for dialogs, floating windows, and rules.
--]]
local function center_and_keep_on_screen(c, opts)
    local default_opts = { honor_workarea = true, honor_padding = true }
    local placement_opts = opts or default_opts

    awful.placement.centered(c, placement_opts)

    -- For no_offscreen, we need to ensure we don't pass parent option
    local offscreen_opts = {}
    if opts then
        offscreen_opts.honor_workarea = opts.honor_workarea
        offscreen_opts.honor_padding = opts.honor_padding
    else
        offscreen_opts = default_opts
    end

    awful.placement.no_offscreen(c, offscreen_opts)
end

--[[
    Handles geometry for new clients:
    - Fullscreen: fills screen geometry
    - Maximized: fills workarea with gaps applied
    - Transient: centered on parent
--]]
capi.client.connect_signal("request::manage", function(c)
    if c.fullscreen then
        c:geometry(c.screen.geometry)
    elseif c.maximized then
        local workarea = c.screen.workarea
        c:geometry({
            x = workarea.x + dpi(3),
            y = workarea.y + dpi(3),
            width = workarea.width - dpi(6),
            height = workarea.height - dpi(6)
        })
    elseif c.transient_for then
        center_and_keep_on_screen(c, { parent = c.transient_for })
    end
end)

--[[
    Defines client rules for window behavior:
    - Global: applies to all clients
    - Titlebars: enabled for normal/dialog types
    - mpv: sets default size
    - Xephyr: fixed size and centered
    - Floating: sets specific clients as floating and centered
--]]
rclient.connect_signal("request::rules", function()
    rclient.append_rule({
        id = "global",
        rule = {},
        properties = {
            titlebars_enabled = true,
            screen = awful.screen.preferred,
            focus = awful.client.focus.filter,
            raise = true,
            size_hints_honor = false,
            placement = center_and_keep_on_screen,
        },
    })

    rclient.append_rule({
        id = "titlebars",
        rule_any = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = true },
    })

    -- rclient.append_rule({
    --     id = "firefox_no_titlebar",
    --     rule_any = { class = { "firefox", "Firefox" } },
    --     properties = { titlebars_enabled = false },
    -- })

    rclient.append_rule({
        rule_any = { class = { "mpv" } },
        properties = { width = 1280, height = 720 },
    })

    local xephyr_props = {
        min_width = 1200,
        max_width = 1200,
        min_height = 800,
        max_height = 800,
        size_hints_honor = true,
        titlebars_enabled = false,
        floating = true,
        raise = true,
        centered = true,
        screen = awful.screen.preferred,
        placement = center_and_keep_on_screen,
        ontop = true,
    }
    rclient.append_rule({
        id = "xephyr_fixed_size",
        rule_any = { class = { "xephyr_1", "Xephyr" } },
        properties = xephyr_props,
    })

    local floating_classes = {
        "Arandr",
        "Blueman-manager",
        "Gpick",
        "Kruler",
        "Sxiv",
        "Tor Browser",
        "Vlc",
        "xtightvncviewer",
        "nvidia-settings",
        "ark",
        "org.gnome.FileRoller",
    }
    rclient.append_rule({
        id = "floating",
        rule_any = {
            instance = { "copyq", "pinentry" },
            class = floating_classes,
            name = { "Event Tester" },
            role = { "AlarmWindow", "ConfigManager", "pop-up" },
        },
        properties = {
            titlebars_enabled = true,
            floating = true,
            raise = true,
            size_hints_honor = true,
            centered = true,
            screen = awful.screen.preferred,
            placement = center_and_keep_on_screen,
        },
    })
end)

--[[
    Sloppy focus implementation:
    Focuses client under mouse pointer when mouse enters a client.
--]]
local function activate_under_pointer()
    local c = capi.mouse.current_client
    if c then
        c:activate({ context = "mouse_enter", raise = false })
    end
end

local gears = require("gears")
local focus_timer = gears.timer({
    autostart = true,
    timeout = 0.2,
    single_shot = true,
    callback = activate_under_pointer,
})

--[[
    Starts focus timer for workspace and client events.
    Ensures correct focus after workspace switch, client close, or tag change.
--]]
local function start_focus_timer()
    focus_timer:start()
end

capi.client.connect_signal("mouse::enter", activate_under_pointer)
capi.tag.connect_signal("property::selected", start_focus_timer)
capi.client.connect_signal("request::unmanage", start_focus_timer)
capi.client.connect_signal("property::tags", function(c)
    if not c.floating then
        start_focus_timer()
    end
end)

--[[
    Handles new client management:
    - Sets non-floating clients as slave
    - Ensures clients are placed on screen after startup or screen changes
--]]
capi.client.connect_signal("manage", function(c)
    if not c.floating then
        awful.client.setslave(c)
    end
    if
        awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position
    then
        awful.placement.no_offscreen(c)
    end
end)

--[[
    Restores focus to previous client:
    Used after minimizing, closing, or switching workspaces.
--]]
local function focus_back()
    local s = awful.screen.focused()
    local c = awful.client.focus.history.get(s, 0)
    if c then
        capi.client.focus = c
        c:raise()
    end
end

capi.client.connect_signal("property::minimized", focus_back)
capi.client.connect_signal("unmanage", focus_back)
capi.tag.connect_signal("property::selected", focus_back)

--[[
    Client shape management:
    Applies rounded corners to clients except when maximized or fullscreen.
--]]
local function update_client_shape(c)
	if c.maximized or c.fullscreen then
		c.shape = nil
	else
		c.shape = shapes.rrect(dpi(12))
	end
end

-- Apply shape when client is managed
capi.client.connect_signal("manage", function(c)
    update_client_shape(c)
end)

-- Update shape when client state changes
capi.client.connect_signal("property::maximized", function(c)
    update_client_shape(c)
    -- Apply gaps when maximizing
    if c.maximized then
        local workarea = c.screen.workarea
        c:geometry({
            x = workarea.x + dpi(3),
            y = workarea.y + dpi(3),
            width = workarea.width - dpi(6),
            height = workarea.height - dpi(6)
        })
    end
end)
capi.client.connect_signal("property::fullscreen", update_client_shape)
capi.client.connect_signal("property::geometry", function(c)
	-- Small delay to ensure geometry changes are processed
	require("gears").timer.delayed_call(function()
		if c.valid then
			update_client_shape(c)
		end
	end)
end)

--[[
Window opacity management (matching picom opacity rules):
- Normal windows: 0.95 (from picom wintypes)
- Inactive windows: 0.90 (from picom inactive-opacity)
- Active/focused: 1.0
- Specific app rules from picom configuration
--]]
local opacity_rules = {
	-- i3lock: 100%
	{ rule = { class = "i3lock" }, properties = { opacity = 1.0 } },
	-- Dunst: 60%
	{ rule = { class = "Dunst" }, properties = { opacity = 0.6 } },
	-- kitty focused: 85%, unfocused: 80%
	{ rule = { class = "kitty" }, properties = { opacity = 0.85 } },
	-- awesome: 95%
	{ rule = { class = "awesome" }, properties = { opacity = 0.95 } },
}

local function apply_opacity(c)
	-- Skip certain window types
	if c.type == "desktop" then
		return
	end

	-- Check opacity rules
	for _, rule in ipairs(opacity_rules) do
		if rule.rule.class and c.class == rule.rule.class then
			c.opacity = rule.properties.opacity
			return
		end
	end

	-- Default opacity based on focus state
	if c.focused then
		c.opacity = beautiful.active_opacity or 1.0
	else
		c.opacity = beautiful.inactive_opacity or 0.90
	end
end

-- Apply opacity on focus change
capi.client.connect_signal("focus", function(c)
	-- Don't override app-specific opacity rules
	local is_kitty = c.class == "kitty"
	if is_kitty then
		c.opacity = 0.85
	else
		c.opacity = beautiful.active_opacity or 1.0
	end
end)

capi.client.connect_signal("unfocus", function(c)
	-- Don't override app-specific opacity rules
	local is_kitty = c.class == "kitty"
	if is_kitty then
		c.opacity = 0.80
	else
		c.opacity = beautiful.inactive_opacity or 0.90
	end
end)

-- Apply opacity on manage
capi.client.connect_signal("manage", apply_opacity)

-- Window type specific rules (matching picom wintypes)
capi.client.connect_signal("manage", function(c)
	-- Tooltip: opacity 1, full-shadow
	if c.type == "tooltip" then
		c.opacity = 1.0
	-- Dock: opacity 1, no blur, no rounded corners
	elseif c.type == "dock" then
		c.opacity = 1.0
		c.shape = nil
	-- Popup menu: opacity 0.95
	elseif c.type == "popup_menu" then
		c.opacity = 0.95
	-- Dropdown menu: opacity 0.9
	elseif c.type == "dropdown_menu" then
		c.opacity = 0.9
	-- Normal: opacity 0.95
	elseif c.type == "normal" then
		c.opacity = 0.95
	end
end)

-- Exclusions for opacity (matching picom focus-exclude)
local opacity_exclude = {
	class = { "i3lock", "polybar" },
	type = { "desktop", "dock" },
}

local function should_exclude_opacity(c)
	for _, cls in ipairs(opacity_exclude.class or {}) do
		if c.class == cls then return true end
	end
	for _, t in ipairs(opacity_exclude.type or {}) do
		if c.type == t then return true end
	end
	return false
end
