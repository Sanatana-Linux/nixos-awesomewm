-- ui/bar/modules/control_panel_button.lua
-- Encapsulates the wibar button for the control panel.

local awful = require("awful")
local beautiful = require("beautiful")
local modules = require("modules")
local control_panel = require("ui.control_panel").get_default()
local dpi = beautiful.xresources.apply_dpi

-- Creates a button to toggle the control panel.
-- Uses SVG icons provided by the theme.
-- @return widget The control panel button widget.
return function()
	return modules.hover_button({
		buttons = {
			awful.button({}, 1, function()
				control_panel:toggle()
			end),
		},
		forced_width = dpi(31),
		-- Use theme gradients for background
		bg_normal = beautiful.bg_gradient_button,
		bg_hover = beautiful.bg_gradient_button_alt,
		fg_normal = beautiful.fg,
		fg_hover = beautiful.fg,
		shape = beautiful.rrect(dpi(8)),
		-- Pass the normal and hover icon surfaces from the theme
		label = beautiful.text_icons.dash,

	})
end
