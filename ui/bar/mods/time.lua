local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful").xresources.apply_dpi
local helpers = require("helpers")

local hourminutes = helpers.mkbtn(

    {
        {
            font = beautiful.prompt_font .. " 14",
            format = "%I:%M",
            align = "center",
            valign = "center",
            widget = wibox.widget.textclock,
            fg = beautiful.fg3,
        },
        widget = wibox.container.place,
        valign = "center",
    },
    beautiful.bg_gradient_button,
    beautiful.bg_gradient_button2,
    dpi(5),
    dpi(84),
    dpi(32)
)
hourminutes:add_button(awful.button({}, 1, function()
    awesome.emit_signal("toggle::moment")
end))

return hourminutes
