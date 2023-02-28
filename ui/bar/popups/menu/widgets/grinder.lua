local wibox = require "wibox"
local beautiful = require "beautiful"
local gears = require "gears"
local dpi = beautiful.xresources.apply_dpi
local awful = require "awful"



local time = 0
local updater
local widget

local start_btn
start_btn = utilities.pointer_on_focus(wibox.widget {
    id = 'button_bg',
    widget = wibox.container.background,
    bg = beautiful.dimblack,
    shape = utilities.mkroundedrect(),
    buttons = awful.button {
        modifiers = {},
        button = 1,
        on_press = function ()
            if updater.started then
                updater:stop()
                start_btn:get_children_by_id('text')[1].text = 'start the grind'
            else
                updater:start()
                start_btn:get_children_by_id('text')[1].text = 'stop the grind'
            end
        end
    },
    {
        widget = wibox.container.margin,
        margins = dpi(5),
        {
            id = 'text',
            widget = wibox.widget.textbox,
            font = beautiful.font .. " 10",
            text = 'start the grind',
        }
    }
})

start_btn:connect_signal("mouse::enter",function ()
    start_btn.bg = beautiful.bg_focus
end)
start_btn:connect_signal("mouse::leave",function ()
    start_btn.bg = beautiful.dimblack
end)

widget = wibox.widget {
    widget = wibox.container.background,
    bg = beautiful.dimblack,
    shape = utilities.mkroundedrect(),
    {
        widget = wibox.container.margin,
        margins = dpi(5),
        {
            layout = wibox.layout.align.vertical,
            {
                widget = wibox.container.margin,
                margins = {
                    bottom = dpi(5)
                },
                {
                    widget = wibox.container.place,
                    halign = 'center',
                    valign = 'center',
                    start_btn
                }
            },
            {
                id = 'second',
                widget = wibox.container.arcchart,
                paddings = dpi(3),
                colors = { beautiful.fg_normal },
                max_value = 60,
                thickness = dpi(4),
                forced_height = dpi(70),
                {
                    id = 'minute',
                    widget = wibox.container.arcchart,
                    paddings = dpi(3),
                    colors = { beautiful.grey },
                    max_value = 60,
                    thickness = dpi(4),
                    {
                        id = 'hour',
                        widget = wibox.container.arcchart,
                        paddings = dpi(5),
                        colors = { beautiful.bg_focus },
                        max_value = 24,
                        thickness = dpi(4),
                        wibox.widget.base.make_widget()
                    }
                }
            },
            {
                widget = wibox.container.margin,
                margins = {
                    top = dpi(5)
                },
                {
                    widget = wibox.container.place,
                    halign = 'center',
                    {
                        id = 'time',
                        widget = wibox.widget.textbox,
                        font = beautiful.font .. " 10",
                        text = ""
                    }
                }
            }
        }
    }
}

local function update ()
    local h,m,s = math.floor(time/3600), math.floor(time/60) % 60, time % 60
    widget:get_children_by_id('hour')[1].values = { h }
    widget:get_children_by_id('minute')[1].values = { m }
    widget:get_children_by_id('second')[1].values = { s }
    widget:get_children_by_id('time')[1].text = (h ~= 0 and h .. "h " or "") .. m .. "m " .. s .. "s"
end

updater = gears.timer {
    timeout = 1,
    callback = function ()
        time = time + 1
        update()
    end
}

return widget
