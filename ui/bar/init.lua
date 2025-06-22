-- ui/bar/init.lua
-- This module defines and assembles the main status bar (wibar) for AwesomeWM.
-- It now loads its components from the `ui/bar/modules/` directory,
-- improving modularity and maintainability.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- Load wibar component modules
local launcher_button = require("ui.bar.modules.launcher_button")
local control_panel_button = require("ui.bar.modules.control_panel_button")
local time_widget = require("ui.bar.modules.time_widget")
local tray_widget = require("ui.bar.modules.tray_widget")
local layoutbox_widget = require("ui.bar.modules.layoutbox_widget")
local taglist_widget = require("ui.bar.modules.taglist_widget")
local tasklist_widget = require("ui.bar.modules.tasklist_widget")

local bar = {}

-- Creates the wibar for secondary screens.
-- Contains only taglist and tasklist for a minimal setup.
-- @param s screen The screen object.
-- @return wibar The wibar for the secondary screen.
function bar.create_secondary(s)
	local wibar = awful.wibar({
		position = "bottom",
		ontop = true,
		screen = s,
		height = dpi(45),
		border_width = beautiful.border_width,
		border_color = beautiful.fg_alt .. '99',
		bg = beautiful.bg .. '99',
		margins = {
			left = -beautiful.border_width,
			right = -beautiful.border_width,
			top = 0,
			bottom = -beautiful.border_width,
		},
		widget = {
			layout = wibox.layout.align.horizontal,
			-- Left
			{
				widget = wibox.container.margin,
				margins = dpi(7),
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = dpi(5),
					taglist_widget(s),
				},
			},
			-- Center
			{
				widget = wibox.container.margin,
				margins = dpi(7),
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = dpi(12),
					tasklist_widget(s),
				},
			},
			-- Right
			{
				-- Empty placeholder
			},
		},
	})
	return wibar
end

-- Creates the wibar for the primary screen.
-- Contains a full set of widgets: launcher, taglist, tasklist, tray, layoutbox, time, and control panel.
-- @param s screen The screen object.
-- @return wibar The wibar for the primary screen.
function bar.create_primary(s)
	local wibar = awful.wibar({
		position = "bottom",
		ontop = true,
		screen = s,
		height = dpi(48),
		border_width = dpi(0),
		border_color = beautiful.bg .. '66',
		bg = beautiful.bg .. '99',
		margins = {
			left = -beautiful.border_width,
			right = -beautiful.border_width,
			top = 0,
			bottom = -beautiful.border_width,
		},
		widget = {
			layout = wibox.layout.align.horizontal,
			{ -- Left widgets
				widget = wibox.container.margin,
				margins = dpi(7),
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = dpi(8),
					launcher_button(),
					taglist_widget(s),
				},
			},
			{ -- Center widgets (tasklist)
				widget = wibox.container.margin,
				margins = dpi(7),
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = dpi(8),
					tasklist_widget(s),
				},
			},
			{ -- Right widgets
				widget = wibox.container.margin,
				margins = {
					top = dpi(7),
					bottom = dpi(7),
					left = 0,
					right = dpi(7),
				},
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = dpi(8),
					tray_widget(),
					layoutbox_widget(s),
					time_widget(),
					control_panel_button(),
				},
			},
		},
	})
	return wibar
end

return bar
