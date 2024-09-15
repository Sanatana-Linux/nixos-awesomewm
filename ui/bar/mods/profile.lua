local wibox = require("wibox")
local helpers = require("helpers")
local beautiful = require("beautiful")
local awful = require("awful")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi

local profile = helpers.mkbtn(
    {
        widget = wibox.widget.imagebox,
        image = gears.color.recolor_image(beautiful.pfp, beautiful.fg),
        resize = true,
    },
    beautiful.bg_gradient_button, -- normal
    beautiful.bg_gradient_button2, -- hover
    dpi(5), -- radius
    dpi(40), -- width
    dpi(40) -- height
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
