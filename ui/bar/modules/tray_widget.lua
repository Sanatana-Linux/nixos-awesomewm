-- ui/bar/modules/tray_widget.lua
-- Encapsulates the wibar widget for the system tray.
-- Updated to correctly use icon surfaces from the theme.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- Creates a system tray widget.
-- It's initially hidden and can be revealed by clicking a button.
-- @return widget The system tray widget.
return function()
	local visibility = false

	local systray = wibox.widget {
		widget = wibox.container.margin,
		margins = { top = dpi(4), bottom = dpi(4) },
		{
			widget = wibox.widget.systray
		}
	}

	local widget = wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_alt,
		shape = beautiful.rrect(dpi(8)),
		{
			widget = wibox.container.margin,
			margins = { left = dpi(8), right = dpi(8) },
			{
				id = "items-layout",
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(8),
				{
					id = "reveal-button",
					widget = wibox.widget.textbox,
					markup = beautiful.text_icons.arrow_left
				}
			}
		}
	}

	local items_layout = widget:get_children_by_id("items-layout")[1]
	local reveal_button = widget:get_children_by_id("reveal-button")[1]

	reveal_button:buttons {
		awful.button({}, 1, function()
			if not visibility then
				visibility = true
				items_layout:insert(2, systray)
				reveal_button:set_markup(beautiful.text_icons.arrow_right)
			else
				visibility = false
				items_layout:remove(2)
				reveal_button:set_markup(beautiful.text_icons.arrow_left)
			end
		end)
	}

	widget:connect_signal("mouse::enter", function(w)
		beautiful.bg_systray = beautiful.bg_gradient_button_alt
		w:set_bg(beautiful.bg_gradient_button_alt)
	end)

	widget:connect_signal("mouse::leave", function(w)
		beautiful.bg_systray = beautiful.bg_gradient_button
		w:set_bg(beautiful.bg_gradient_button)
	end)

	return widget

end
