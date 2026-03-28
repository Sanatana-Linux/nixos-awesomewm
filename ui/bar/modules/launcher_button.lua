-- ui/bar/modules/launcher_button.lua
-- Encapsulates the wibar button for the application launcher.

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gfs = require("gears.filesystem")
local launcher = require("ui.popups.launcher").get_default()
local dpi = beautiful.xresources.apply_dpi
local shapes = require("modules.shapes.init")

local icon_path = gfs.get_configuration_dir() .. "ui/bar/modules/launcher_button/icons/nix.svg"

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
                image = icon_path,
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
