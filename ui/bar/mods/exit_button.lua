local wibox = require("wibox")
local awful = require("awful")
local helpers = require("helpers")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local exit_button = helpers.mkbtn(

    {
        align = "center",
        font = beautiful.icon .. " 24",
        markup = helpers.colorize_text("󰐥", beautiful.red),
        widget = wibox.widget.textbox,
        buttons = {
            awful.button({}, 1, function()
                awesome.emit_signal("toggle::exit")
            end),
        },
    },

    beautiful.bg_gradient_button,     -- normal bg
    beautiful.bg_gradient_button_alt, -- hover bg
    dpi(5),                           --radius
    dpi(32),                          --width
    dpi(32)                           --height
)


return exit_button
