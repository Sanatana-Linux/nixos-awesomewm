--  _____                            __
-- |     |_.---.-.--.--.-----.--.--.|  |_
-- |       |  _  |  |  |  _  |  |  ||   _|
-- |_______|___._|___  |_____|_____||____|
--               |_____|
--  ______
-- |   __ \.-----.--.--.
-- |   __ <|  _  |_   _|
-- |______/|_____|__.__|
-- ------------------------------------------------- --
--

-- Required modules
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
-- Utility function to create rounded rectangle shape
local function mkroundedrect()
    -- Implement the rounded rectangle shape creation logic here
end
-- Create the base layout
local base_layout = wibox.widget {
    spacing = dpi(32),
    forced_num_cols = 6,
    layout = wibox.layout.grid.vertical,
}
-- Define the widget template
local widget_template = {
    {
        {
            id = "icon_role",
            forced_height = dpi(48),
            forced_width = dpi(48),
            widget = wibox.widget.imagebox,
            shape = mkroundedrect(),
        },
        margins = dpi(16),
        widget = wibox.container.margin,
        shape = mkroundedrect(),
    },
    id = "background_role",
    forced_width = dpi(64),
    forced_height = dpi(64),
    bg = beautiful.grey .. "44",
    shape = mkroundedrect(),
    widget = wibox.container.background,
}
-- Create the layout list with optimized configurations
local ll = awful.widget.layoutlist {
    spacing = dpi(32),
    base_layout = base_layout,
    widget_template = widget_template,
}
-- Create the layout popup with optimized configurations
local layout_popup = awful.popup {
    widget = wibox.widget {
        ll,
        margins = dpi(32),
        screen = mouse.screen,
        widget = wibox.container.margin,
    },
    border_width = dpi(2.25),
    border_color = beautiful.grey,
    bg = beautiful.bg_normal .. "aa",
    shape = mkroundedrect(),
    screen = mouse.screen,
    placement = awful.placement.centered,
    ontop = true,
    visible = false,
}
-- Timer for layout popup
layout_popup.timer = gears.timer { timeout = 3 }
layout_popup.timer:connect_signal("timeout", function()
    layout_popup.visible = false
    layout_popup.screen = mouse.screen
end)
layout_popup.screen = screen.current
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
