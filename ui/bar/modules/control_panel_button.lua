-- ui/bar/modules/control_panel_button.lua

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gfs = require("gears.filesystem")
local dpi = beautiful.xresources.apply_dpi
local shapes = require("modules.shapes.init")

local icon_path = gfs.get_configuration_dir()
	.. "ui/bar/modules/control_panel_button/icons/settings.svg"

return function()
	local control_panel = require("ui.popups.control_panel").get_default()
	local widget = wibox.widget({
		widget = wibox.container.background,
		forced_width = dpi(32),
		forced_height = dpi(32),
		bg = beautiful.bg_gradient_button,
		shape = shapes.rrect(8),
		buttons = {
			awful.button({}, 1, function()
				control_panel:toggle()
			end),
		},
		{
			widget = wibox.container.margin,
			margins = dpi(2),
			{
				widget = wibox.widget.imagebox,
				image = icon_path,
				resize = true,
			},
		},
	})

	widget:connect_signal("mouse::enter", function(w)
		w:set_bg(beautiful.bg_gradient_button_alt)
	end)
	widget:connect_signal("mouse::leave", function(w)
		w:set_bg(beautiful.bg_gradient_button)
	end)

	return widget
end
