local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
local mouse = mouse
local shapes = require("modules.shapes.init")

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
            shape = shapes.rrect(5),
        },
        margins = dpi(16),
        widget = wibox.container.margin,
        shape = shapes.rrect(5),
    },
    id = "background_role",
    forced_width = dpi(108),
    forced_height = dpi(108),
    bg = beautiful.bg_normal .. "00",
    shape = shapes.rrect(5),
    widget = wibox.container.background,
}

beautiful.layoutlist_bg_selected = beautiful.bg_urg
beautiful.layoutlist_bg_normal = "#00000000"
beautiful.layoutlist_shape_selected = shapes.rrect(8)
beautiful.layoutlist_shape_border_width_selected = dpi(1.75)
beautiful.layoutlist_shape_border_color_selected = beautiful.fg_alt .. "88"

local ll = awful.widget.layoutlist({
    spacing = dpi(32),
    base_layout = base_layout,
    widget_template = widget_template,
})
-- Create the layout list with optimized configurations

-- Create the layout popup with optimized configurations
local layout_popup = awful.popup({
    widget = wibox.widget({
        ll,
        margins = dpi(32),
        screen = mouse.screen,
        widget = wibox.container.margin,
    }),
    border_width = dpi(2.25),
    border_color = beautiful.bg_normal .. "44",
    bg = beautiful.bg .. "cc",
    shape = shapes.rrect(12),
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

local osd = {}

function osd.show()
    layout_popup.visible = true
    layout_popup.timer:again()
end

function osd.hide()
    layout_popup.visible = false
    layout_popup.timer:stop()
end

function osd.get_default()
    return osd
end

return osd
