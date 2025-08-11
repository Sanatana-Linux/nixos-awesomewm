-- ui/bar/modules/launcher_button.lua
-- Encapsulates the wibar button for the application launcher.
-- Now uses the SVG icon from the theme.

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local launcher = require("ui.popups.launcher").get_default()
local dpi = beautiful.xresources.apply_dpi
local shapes = require('modules.shapes.init')

-- Creates a button to toggle the application launcher using the SVG icon.
-- @return widget The launcher button widget.
return function()
    local widget = wibox.widget({
        widget = wibox.container.background,
        forced_width = dpi(32),
        forced_height = dpi(32),
        bg = beautiful.bg_gradient_button,
        shape = shapes.rrect(8),
        buttons = {
            awful.button({}, 1, function()
                launcher:toggle()
            end),
        },
        {
            widget = wibox.container.margin,
            margins = dpi(2),
            {
                id = "icon",
                widget = wibox.widget.imagebox,
                image = beautiful.launcher_icon,
                resize = true,
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
