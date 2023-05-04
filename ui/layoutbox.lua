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

local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")



local ll =
    awful.widget.layoutlist {
    spacing = dpi(32),
    base_layout = wibox.widget {
        spacing = dpi(32),
        forced_num_cols = 5,
        layout = wibox.layout.grid.vertical
    },
    -- ------------------------------------------------- --

    widget_template = {
      
            {
                {
                    id = 'icon_role',
                    forced_height = dpi(48),
                    forced_width = dpi(48),
                    widget = wibox.widget.imagebox,
                    shape = utilities.mkroundedrect(10)
                },
                margins = dpi(15),
                widget = wibox.container.margin,
                shape = utilities.mkroundedrect(10)
            },
  
        id = 'background_role',
        forced_width = dpi(64),
        forced_height = dpi(64),
        bg = beautiful.widget_back,
     shape = utilities.mkroundedrect(10),
        widget = wibox.container.background
    }
}
-- ------------------------------------------------- --
local layout_popup =
    awful.popup {
    widget = wibox.widget {
        {
            ll,
            margins = dpi(32),
            screen = mouse.screen,
            widget = wibox.container.margin
        },
        widget = wibox.container.background
    },
    border_width = dpi(3.25),
    border_color = beautiful.grey,
    bg = beautiful.bg_normal,
 shape = utilities.mkroundedrect(),
    screen = mouse.screen,
    placement = awful.placement.centered,
    ontop = true,
    visible = false
}
-- ------------------------------------------------- --
layout_popup.timer = gears.timer {timeout = 3}
layout_popup.timer:connect_signal(
    'timeout',
    function()
        layout_popup.visible = false
        layout_popup.screen = mouse.screen
    end
)
layout_popup.screen = mouse.current
-- ------------------------------------------------- --
function gears.table.iterate_value(t, value, step_size, filter, start_at)
    local k = gears.table.hasitem(t, value, true, start_at)
    if not k then
        return
    end
    step_size = 1
    local new_key = gears.math.cycle(#t, k + step_size)
    if filter and not filter(t[new_key]) then
        for i = 1, #t do
            local k2 = gears.math.cycle(#t, new_key + i)
            if filter(t[k2]) then
                return t[k2], k2
            end
        end
        return
    end
    return t[new_key], new_key
end
-- ------------------------------------------------- --
awesome.connect_signal(
    'layout::changed:next',
    function()
        awful.layout.inc(1)
        layout_popup.visible = true
        layout_popup.timer:start()
    end
)
awesome.connect_signal(
    'layout::changed:prev',
    function()
        awful.layout.inc(-1)
        layout_popup.visible = true
        layout_popup.timer:start()
    end
)
-- ------------------------------------------------- --
