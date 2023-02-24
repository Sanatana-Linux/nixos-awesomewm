---@diagnostic disable: undefined-global

local gears = require 'gears'
local awful = require 'awful'

gears.timer {
    timeout = 100,
    autostart = true,
    call_now = true,
    callback = function ()
        awful.spawn.easy_async_with_shell('whoami', function (user)
            awesome.emit_signal('user::name', utilities.trim(user))
        end)
    end
}