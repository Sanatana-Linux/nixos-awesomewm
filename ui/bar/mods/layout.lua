local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")

local widget = helpers.mkbtn(
    awful.widget.layoutbox, -- template
    beautiful.bg_gradient_button, -- normal
    beautiful.bg_gradient_button2, --hover
    5, --radius
    32, --w
    32 --h
)

widget:add_button(
    awful.button({}, 1, function()
        awesome.emit_signal("layout::changed:next")
    end),
    awful.button({}, 1, function()
        awesome.emit_signal("layout::changed:next")
    end)
)
return widget
