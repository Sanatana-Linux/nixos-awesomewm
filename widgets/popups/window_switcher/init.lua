local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

local elems = require("widgets.popups.window_switcher.elements")

local window_switcher = function(s)
    local winlist = wibox.widget({
        widget = wibox.container.margin,
        margins = dpi(14),
        elems(),
    })

    local container = awful.popup({
        widget = wibox.container.background,
        ontop = true,
        visible = false,
        stretch = false,
        screen = s,
        shape = utilities.widgets.mkroundedrect(),
        placement = awful.placement.centered,
        bg = beautiful.dimblack .. "66",
        border_width = dpi(1),
        border_color = beautiful.grey .. "33",
    })

    container:setup({
        winlist,
        layout = wibox.layout.fixed.vertical,
    })

    awesome.connect_signal("window_switcher::toggle", function()
        container.visible = not container.visible
    end)
end

awful.screen.connect_for_each_screen(function(s)
    window_switcher(s)
end)
