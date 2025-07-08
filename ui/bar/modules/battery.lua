local wibox = require("wibox")
local helpers = require("helpers")
local beautiful = require("beautiful")
local awful = require("awful")
local dpi = beautiful.xresources.apply_dpi


local widget = helpers.mkbtn({
    {
        {
            {
                font = beautiful.prompt_font .. " 12",
                markup = helpers.colorize_text("25%", beautiful.fg),
                valign = "center",
                align = "center",
                id = "batvalue",
                widget = wibox.widget.textbox,
            },
            {
                max_value        = 100,
                value            = 69,
                id               = "prog",
                forced_height    = 20,
                forced_width     = 40,
                paddings         = 3,
                border_color     = beautiful.fg .. "99",
                background_color = beautiful.mbg,
                bar_shape        = helpers.rrect(2),
                color            = beautiful.blue,
                border_width     = 1.25,
                shape            = helpers.rrect(5),
                widget           = wibox.widget.progressbar
            },
            {
                {
                    bg = beautiful.fg .. "99",
                    forced_height = 10,
                    forced_width = 2,
                    shape = helpers.rrect(10),
                    widget = wibox.container.background,
                },
                widget = wibox.container.place,
                valign = "center",
            },
            spacing = 3,
            layout = wibox.layout.fixed.horizontal

        },
        widget = wibox.container.margin,
        left = dpi(8),
        right = dpi(8),
        top = dpi(5),
        bottom = dpi(5)

    },
    layout = wibox.layout.fixed.horizontal,
    spacing = 10
}, beautiful.bg_gradient_button, beautiful.bg_gradient_button_alt, dpi(5))
awesome.connect_signal("signal::battery", function(value)
    local b = widget:get_children_by_id("prog")[1]
    local v = widget:get_children_by_id("batvalue")[1]
    v.markup = helpers.colorize_text(value .. "%", beautiful.fg)
    b.value = value
    if value > 80 then
        b.color = beautiful.green
    elseif value > 20 then
        b.color = beautiful.blue
    else
        b.color = beautiful.red
    end
end)

return widget
