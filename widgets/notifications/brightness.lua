---@diagnostic disable: undefined-global
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

local dpi = beautiful.xresources.apply_dpi

local width = dpi(50)
local height = dpi(300)

local active_color_1 = {
    type = "linear",
    from = { 0, 0 },
    to = { 200, 50 }, -- replace with w,h later
    stops = { { 0, beautiful.fg_focus }, { 0.50, beautiful.fg_normal } },
}

local bright_icon = wibox.widget({
    image = icons.brightness,
    align = "center",
    valign = "center",
    widget = wibox.widget.imagebox,
})

local bright_adjust = awful.popup({
    type = "notification",
    maximum_width = width,
    maximum_height = height,
    visible = false,
    ontop = true,
    widget = wibox.container.background,
    bg = "#00000000",
    placement = function(c)
        awful.placement.right(c, { margins = { right = 10 } })
    end,
})

local bright_bar = wibox.widget({
    bar_shape = gears.shape.rounded_rect,
    shape = gears.shape.rounded_rect,
    background_color = beautiful.bg_contrast,
    color = active_color_1,
    max_value = 100,
    min_value = 0,
    widget = wibox.widget.progressbar,
})

local bright_ratio = wibox.widget({
    layout = wibox.layout.ratio.vertical,
    {
        { bright_bar, direction = "east", widget = wibox.container.rotate },
        top = dpi(20),
        left = dpi(20),
        right = dpi(20),
        widget = wibox.container.margin,
    },
    {
        bright_icon,
        top = dpi(10),
        left = dpi(10),
        right = dpi(10),
        bottom = dpi(10),
        widget = wibox.container.margin,
    },
    nil,
})

bright_ratio:adjust_ratio(2, 0.72, 0.28, 0)

bright_adjust.widget = wibox.widget({
    bright_ratio,
    shape = utilities.widgets.mkroundedrect(),
    border_width = dpi(0.75),
    border_color = beautiful.grey .. "cc",
    bg = beautiful.bg_normal .. "33",
    widget = wibox.container.background,
})

-- create a 3 second timer to hide the volume adjust
-- component whenever the timer is started
local hide_bright_adjust = gears.timer({
    timeout = 3,
    autostart = true,
    callback = function()
        bright_adjust.visible = false
    end,
})

awesome.connect_signal("signal::brightness", function(value)
    bright_bar.value = value
    if bright_adjust.visible then
        hide_bright_adjust:again()
    else
        bright_adjust.visible = true
        hide_bright_adjust:start()
    end
end)
