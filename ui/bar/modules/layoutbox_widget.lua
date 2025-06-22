-- ui/bar/modules/layoutbox_widget.lua
-- Encapsulates the wibar widget for the layoutbox.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- Creates a layout box widget to display and change the current layout.
-- @param s screen The screen object.
-- @return widget The layout box widget.
return function(s)
	local widget = wibox.widget({
		widget = wibox.container.background,
		bg = beautiful.bg_gradient_button,
		shape = beautiful.rrect(dpi(8)),
		buttons = {
			awful.button({}, 1, function()
				awful.layout.inc(1)
			end),
			awful.button({}, 3, function()
				awful.layout.inc(-1)
			end),
		},
		{
			widget = wibox.container.margin,
			margins = dpi(7), -- Uniform margin
			{
				widget = awful.widget.layoutbox({
					screen = s,
					buttons = {}, -- Remove default buttons as they are on parent
				}),
			},
		},
	})

	-- Hover effects
	widget:connect_signal("mouse::enter", function(w)
		w:set_bg(beautiful.bg_gradient_button_alt)
	end)

	widget:connect_signal("mouse::leave", function(w)
		w:set_bg(beautiful.bg_gradient_button)
	end)

	return widget
end
