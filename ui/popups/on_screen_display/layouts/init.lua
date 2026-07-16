--- Layout-switch OSD popup.
-- Shows a grid of layout icons centered on screen when the layout
-- changes (triggered by `layout::changed:next`/`:prev` signals).
-- Includes a cooldown lock to prevent rapid cycling. Also patches
-- `gears.table.iterate_value` for cyclic table iteration.
-- @module ui.popups.on_screen_display.layouts

local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
local mouse = mouse
local shapes = require("modules.style.shapes.init")

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

-- Cooldown lock to prevent rapid layout switching
-- Gives clients time to rearrange before the next change
local layout_lock = false
local LAYOUT_COOLDOWN = 1.5
local unlock_timer = gears.timer({
    timeout = LAYOUT_COOLDOWN,
    single_shot = true,
    autostart = false,
    callback = function()
        layout_lock = false
    end,
})

--- Change layout by delta and show the OSD.
-- Applies a cooldown lock to prevent rapid cycling.
-- Fires `awful.layout.inc(dir)` then shows the popup.
-- @tparam integer dir 1 for next, -1 for previous
local function change_layout(dir)
    if layout_lock then
        return
    end
    layout_lock = true
    unlock_timer:start()
    awful.layout.inc(dir)
    layout_popup.visible = true
    layout_popup.timer:start()
end

-- Connect signals for layout change events
awesome.connect_signal("layout::changed:next", function()
    change_layout(1)
end)
awesome.connect_signal("layout::changed:prev", function()
    change_layout(-1)
end)

-- Optimized table iteration function
--- Cyclic table iteration: find `value` in `t`, then return the element
-- `step_size` positions forward (wrapping around at the end).
-- Used to make layout cycling work in both directions.
-- Overrides `gears.table.iterate_value`.
-- @tparam table t The table to search
-- @param value The value to find
-- @tparam[opt] integer step_size Steps forward (default 1)
-- @tparam[opt] function filter Optional filter function applied to candidate
-- @tparam[opt] integer start_at Index to start searching from
-- @return The found element, or nil
-- @treturn[1] integer|nil The key of the found element
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

--- Show the layout-switch OSD.
-- The popup reappears with the auto-hide timer reset.
function osd.show()
    layout_popup.visible = true
    layout_popup.timer:again()
end

--- Hide the layout-switch OSD immediately.
function osd.hide()
    layout_popup.visible = false
    layout_popup.timer:stop()
end

--- Singleton accessor: returns the (already-initialised) OSD.
-- @treturn table OSD module with show/hide methods
function osd.get_default()
    return osd
end

return osd
