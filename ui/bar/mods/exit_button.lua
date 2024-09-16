local wibox = require("wibox")
local awful = require("awful")
local helpers = require("helpers")
local beautiful = require("beautiful")


local exit_button = helpers.mkbtn(

    {
        align = "center",
        font = beautiful.icon .. " 24",
        markup = helpers.colorizeText("󰐥", beautiful.red),
        widget = wibox.widget.textbox,
        buttons = {
            awful.button({}, 1, function()
                awesome.emit_signal("toggle::exit")
            end),
        },
    },

    beautiful.bg_gradient_button, -- normal bg
    beautiful.bg_gradient_button2, -- hover bg
    5, --radius
    32, --width
    32 --height
)

exit_button:add_button(awful.button({}, 1, function()
    awesome.emit_signal("toggle::exit")
end))
return exit_button
