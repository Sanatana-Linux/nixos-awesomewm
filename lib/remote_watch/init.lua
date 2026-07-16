---@diagnostic disable: undefined-global
--- Remote-resource watcher.
-- Polls a shell command on a fixed interval, caches its output to a
-- file, and invokes a callback with the new output. Avoids re-running
-- the command when the cache is fresh.
-- @module lib.remote_watch

local awful = require("awful")
local gtimer = require("gears.timer")

--- Start polling a remote command.
-- @tparam string command Shell command whose stdout to watch
-- @tparam number interval Poll interval in seconds
-- @tparam string output_file Cache file path; mtime is checked to skip
--   re-running when the cache is fresh
-- @tparam function callback Called with the command's stdout each tick
-- @treturn table The underlying `gears.timer`
local function new(command, interval, output_file, callback)
    local timer
    timer = gtimer({
        timeout = interval,
        call_now = true,
        autostart = true,
        single_shot = false,
        callback = function()
            awful.spawn.easy_async_with_shell(
                "date -r " .. output_file .. " +%s",
                function(last_update, _, _, exitcode)
                    if exitcode == 1 then
                        awful.spawn.easy_async_with_shell(
                            command .. " | tee " .. output_file,
                            function(out)
                                callback(out)
                            end
                        )
                        return
                    end

                    local diff = os.time() - tonumber(last_update)
                    if diff >= interval then
                        awful.spawn.easy_async_with_shell(
                            command .. " | tee " .. output_file,
                            function(out)
                                callback(out)
                            end
                        )
                    else
                        awful.spawn.easy_async_with_shell(
                            "cat " .. output_file,
                            function(out)
                                callback(out)
                            end
                        )
                        timer:stop()
                        gtimer.start_new(interval - diff, function()
                            awful.spawn.easy_async_with_shell(
                                command .. " | tee " .. output_file,
                                function(out)
                                    callback(out)
                                end
                            )
                            timer:again()
                        end)
                    end
                end
            )
        end,
    })

    return timer
end

return setmetatable({
    new = new,
}, {
    __call = function(_, ...)
        return new(...)
    end,
})
