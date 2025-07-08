-- ui/bar/modules/time_widget.lua
-- Encapsulates the wibar widget for displaying the time and date.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- Creates a widget to display the current time and date.
-- Uses theme gradients for background styling.
-- @return widget The time/date widget.
return function()
    local widget = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg_gradient_button,
        shape = beautiful.rrect(dpi(8)),
        {
            widget = wibox.container.margin,
            margins = { left = dpi(4), right = dpi(4), top = dpi(2) },
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(8),
                {
                    widget = wibox.widget.textclock,
                    font = beautiful.font_name .. " 20",
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
