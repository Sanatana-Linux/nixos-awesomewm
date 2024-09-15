local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local dpi = require("beautiful").xresources.apply_dpi

local notifications_button = helpers.mkbtn(

    {
        align = "center",
        font = beautiful.icon .. " 24",
        markup = helpers.colorizeText("󰂜", beautiful.fg),
        widget = wibox.widget.textbox,
        buttons = {
            awful.button({}, 1, function()
                awesome.emit_signal("toggle::notify")
            end),
        },
    },

    beautiful.bg_gradient_button, --normal
    beautiful.bg_gradient_button2, -- hover
    5, --radius
    32, --width
    32 --height
)

return notifications_button
