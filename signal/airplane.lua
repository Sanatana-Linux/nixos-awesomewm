---@diagnostic disable: undefined-global

local gears = require('gears')
local awful = require('awful')
local fs = gears.filesystem

local airplane = {}

airplane.script_path = fs.get_configuration_dir() .. 'scripts/airplane.sh'

function airplane._invoke_script(args, cb)
    awful.spawn.easy_async_with_shell(airplane.script_path .. ' ' .. args, function (out)
        if cb then
            cb(utilities.trim(out))
        end
    end)
end

function airplane.toggle()
    airplane._invoke_script('toggle')
end

gears.timer {
    timeout = 2,
    call_now = true,
    autostart = true,
    callback = function ()
        airplane._invoke_script('status', function (status)
            awesome.emit_signal('airplane::enabled', status == 'on')
        end)
    end
}

return airplane
