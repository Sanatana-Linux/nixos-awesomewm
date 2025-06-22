-- ui/bar/modules/launcher_button.lua
-- Encapsulates the wibar button for the application launcher.

local awful = require("awful")
local beautiful = require("beautiful")
local modules = require("modules")
local launcher = require("ui.launcher").get_default()
local dpi = beautiful.xresources.apply_dpi

-- Creates a button to toggle the application launcher.
-- Uses SVG icons provided by the theme.
-- @return widget The launcher button widget.
return function()
	return modules.hover_button({
		buttons = {
			awful.button({}, 1, function()
				launcher:toggle()
			end),
		},
		forced_width = dpi(32),
		-- Use theme gradients for background
		bg_normal = beautiful.bg_gradient_button,
		bg_hover = beautiful.bg_gradient_button_alt,
		shape = beautiful.rrect(dpi(8)),
		-- Pass the normal and hover icon surfaces from the theme
		label = beautiful.text_icons.menu,
		fg_normal = beautiful.fg,
		fg_hover = beautiful.fg
		
	})
end
