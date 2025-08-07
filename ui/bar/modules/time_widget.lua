-- ui/bar/modules/time_widget.lua
-- This module defines the wibar widget for displaying the time.
-- It is now interactive, toggling the day_info_panel on click.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local day_info_panel = require("ui.popups.day_info_panel").get_default()
local shapes = require('modules.shapes')

-- Creates a widget to display the current time and date.
-- @return widget The time/date widget.
return function()
    local widget = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg_gradient_button,
        shape = shapes.rrect(8),
        buttons = {
            awful.button({}, 1, function()
                day_info_panel:toggle()
            end),
        },
        {
            widget = wibox.container.margin,
            margins = { left = dpi(5), right = dpi(5), top = dpi(4), bottom = dpi(4) },
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(5),
                {
                    widget = wibox.widget.textclock,
                    font = beautiful.font_name .. " 16",
                    format = "%H:%M", -- Time format
                },
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
