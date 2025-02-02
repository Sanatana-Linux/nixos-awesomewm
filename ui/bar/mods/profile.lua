local wibox = require("wibox")
local helpers = require("helpers")
local beautiful = require("beautiful")
local awful = require("awful")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi

local profile = helpers.mkbtn(
    {
        {
            widget = wibox.widget.imagebox,
            image = gears.color.recolor_image(beautiful.logo, beautiful.fg),
            resize = true,
        },
        widget = wibox.container.margin,
        margins = dpi(4),
    },
    beautiful.bg_gradient_button, -- normal
    beautiful.bg_gradient_button_alt, -- hover
    dpi(5) -- radius
)

profile:add_button(
    awful.button({}, 1, function()
        awesome.emit_signal("toggle::launcher")
    end),

    awful.button({}, 3, function()
        awesome.emit_signal("toggle::dash")
    end)
)
return profile
