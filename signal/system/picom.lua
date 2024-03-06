local awful = require("awful")
local gears = require("gears")

local function emit_picom_status()
  awful.spawn.easy_async("pidof picom", function(stdout)
    local isRunning = string.match(stdout, "%S+") ~= nil
    awesome.emit_signal("signal::picom", isRunning)
  end)
end

gears.timer({
  timeout = 20,
  call_now = true,
  autostart = true,
  callback = emit_picom_status,
})
