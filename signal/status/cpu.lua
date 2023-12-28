local awful = require("awful")
local gears = require("gears")
local cmd =
  [[rga 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}' | sed 's/\./ /g' | awk '{print $1}']]

gears.timer({
  timeout = 5,
  call_now = true,
  autostart = true,
  callback = function()
    awful.spawn.easy_async_with_shell(cmd, function(cpu)
      local cpu_trim = utilities.textual.trim(cpu)
      awesome.emit_signal("cpu::percent", cpu_trim)
    end)
  end,
})
