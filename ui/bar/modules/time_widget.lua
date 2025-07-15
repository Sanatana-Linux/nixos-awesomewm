-- ui/bar/modules/time_widget.lua
-- This module defines the wibar widget for displaying the time.
-- It is now interactive, toggling the day_info_panel on click.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local day_info_panel = require("ui.day_info_panel").get_default()

-- Creates a widget to display the current time and date.
-- @return widget The time/date widget.
return function()
    local widget = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg_gradient_button,
        shape = beautiful.rrect(dpi(8)),
        buttons = {
            awful.button({}, 1, function()
                day_info_panel:toggle()
            end),
        },
        {
            widget = wibox.container.margin,
            margins = { left = dpi(12), right = dpi(12), top = dpi(2) }, -- Increased margins for better spacing
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
