local awful = require("awful")
local gears = require("gears")
local function emit_disk_status()
    awful.spawn.easy_async_with_shell(
        "bash -c \"df / | sed '1d;s/^ //;s/%//'\"",
        function(stdout)
            stdout = stdout:gsub("%s+", "")
            stdout = tonumber(stdout)
            awesome.emit_signal("disk::usage", stdout)
        end
    )
end

gears.timer({
    timeout = 600,
    call_now = true,
    autostart = true,
    callback = function()
        emit_disk_status()
    end,
})
