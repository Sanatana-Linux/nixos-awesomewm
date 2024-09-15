local wibox = require("wibox")
local helpers = require("helpers")
local beautiful = require("beautiful")
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi

local battery = helpers.mkbtn({
    {
        max_value = 100,
        value = 69,
        id = "prog",
        forced_height = dpi(22),
        forced_width = dpi(45),
        paddings = 5,
        border_color = beautiful.fg .. "99",
        background_color = beautiful.mbg,
        bar_shape = helpers.rrect(6),
        color = beautiful.blue,
        border_width = 1.25,
        shape = helpers.rrect(4),
        widget = wibox.widget.progressbar,
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
    spacing = 2,
    layout = wibox.layout.fixed.horizontal,
}, beautiful.bg_gradient, beautiful.bg_gradient2, 5, dpi(58), dpi(32))

awesome.connect_signal("signal::battery", function(value)
    local b = battery:get_children_by_id("prog")[1]
    b.value = value
    if value > 70 then
        b.color = beautiful.green
    elseif value > 20 then
        b.color = beautiful.blue
    else
        b.color = beautiful.red
    end
end)

local battery_tooltip = awful.tooltip({
    objects = { battery },
    text = "None",
    mode = "outside",
    align = "right",
    margin_leftright = dpi(18),
    margin_topbottom = dpi(18),
    shape = helpers.rrect(),
    bg = beautiful.bg .. "88",
    border_color = beautiful.fg3 .. "88",
    border_width = dpi(1),
    preferred_positions = { "right", "left", "top", "bottom" },
})
local get_battery_info = function()
    awful.spawn.easy_async_with_shell(
        "upower -i $(upower -e | grep BAT)",
        function(stdout)
            if stdout == nil or stdout == "" then
                battery_tooltip:set_text("No battery detected!")
                return
            end

            -- Remove new line from the last line
            battery_tooltip:set_text(stdout:sub(1, -2))
        end
    )
end
get_battery_info()

return battery
