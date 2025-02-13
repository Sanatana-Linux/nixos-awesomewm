local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
local mouse = mouse
local helpers = require("helpers")

-- Create the base layout
local base_layout = wibox.widget({
    spacing = dpi(72),
    forced_num_cols = 4,
    layout = wibox.layout.grid.vertical,
})
-- Define the widget template
local widget_template = {
    {
        {
            id = "icon_role",
            forced_height = dpi(96),
            forced_width = dpi(96),
            widget = wibox.widget.imagebox,
            shape = helpers.rrect(5),
        },
        margins = dpi(16),
        widget = wibox.container.margin,
        shape = helpers.rrect(5),
    },
    id = "background_role",
    forced_width = dpi(108),
    forced_height = dpi(108),
    bg = beautiful.fg2 .. "44",
    shape = helpers.rrect(5),
    widget = wibox.container.background,
}
-- Create the layout list with optimized configurations
local ll = awful.widget.layoutlist({
    spacing = dpi(32),
    base_layout = base_layout,
    widget_template = widget_template,
})
-- Create the layout popup with optimized configurations
local layout_popup = awful.popup({
    widget = wibox.widget({
        ll,
        margins = dpi(32),
        screen = mouse.screen,
        widget = wibox.container.margin,
    }),
    border_width = dpi(2.25),
    border_color = beautiful.fg2 .. "44",
    bg = beautiful.bg_normal .. "aa",
    shape = helpers.rrect(12),
    screen = mouse.screen,
    placement = awful.placement.centered,
    ontop = true,
    visible = false,
})
-- Timer for layout popup
layout_popup.timer = gears.timer({ timeout = 1.5 })
layout_popup.timer:connect_signal("timeout", function()
    layout_popup.visible = false
    layout_popup.screen = mouse.screen
end)
layout_popup.screen = mouse.screen
-- Connect signals for layout change events
awesome.connect_signal("layout::changed:next", function()
    awful.layout.inc(1)
    layout_popup.visible = true
    layout_popup.timer:start()
end)
awesome.connect_signal("layout::changed:prev", function()
    awful.layout.inc(-1)
    layout_popup.visible = true
    layout_popup.timer:start()
end)
-- Cache frequently used global variables
local math = math
local table = table
-- Optimized table iteration function
function gears.table.iterate_value(t, value, step_size, filter, start_at)
    local k = table.hasitem(t, value, true, start_at)
    if not k then
        return
    end
    step_size = step_size or 1
    local length = #t
    local new_key = ((k - 1 + step_size) % length) + 1
    if not filter or filter(t[new_key]) then
        return t[new_key], new_key
    end
    for i = 1, length do
        local k2 = ((new_key - 1 + i) % length) + 1
        if filter(t[k2]) then
            return t[k2], k2
        end
    end
end
