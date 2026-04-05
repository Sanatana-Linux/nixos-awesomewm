local awful = require("awful")
local beautiful = require("beautiful")
local gtimer = require("gears.timer")
local naughty = require("naughty")
local wibox = require("wibox")
local dpi = beautiful.xresources.apply_dpi

local lockscreen_body = require("ui.lockscreen.lockscreen_body")
local grab_password = require("ui.lockscreen.grab_password")

local last_hour
local last_minute
local active_color

local function update_time()
    local hour, min = os.date("%H:%M"):match("(%d+):(%d+)")
    local hour = tonumber(hour)
    local min = tonumber(min)

    -- update only if time has changed
    if last_hour == hour and last_minute == min then
        return
    end

    -- Safe access to container
    local container = lockscreen_body:get_children_by_id("container")
    if container and container[1] then
        container[1].border_color = beautiful.fg_alt
    end

    last_hour = hour
    last_minute = min
end

local clock_timer = gtimer({
    timeout = 2,
    call_now = false,
    callback = update_time,
})

-- Add lockscreen to each screen
awful.screen.connect_for_each_screen(function(s)
    s.lockscreen = wibox({
        widget = {
            lockscreen_body,
            widget = wibox.container.place,
            halign = "center",
            valign = "center",
        },
        visible = false,
        ontop = true,
        type = "splash",
        screen = s,
        bg = beautiful.backdrop_color or "#000000AA",
    })
end)

awesome.connect_signal("lockscreen::visible", function(visible)
    if visible then
        grab_password()
        update_time()
        clock_timer:start()
    else
        clock_timer:stop()
    end

    naughty.suspended = visible
    for s in screen do
        s.lockscreen.visible = visible
    end
end)

screen.connect_signal("request::wallpaper", function(s)
    awful.placement.maximize(s.lockscreen)
end)
