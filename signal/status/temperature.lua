-- Provides:
-- signal::temperature
--      temperature (integer - in Celcius)
local awful = require("awful")

local update_interval = 15
local temp_script = [[
  sh -c "
  sensors | rga temp1: | awk '{print $2}' | cut -c 2-3
  "]]

-- Periodically get temperature info
awful.widget.watch(temp_script, update_interval, function(widget, stdout)
  awesome.emit_signal("temperature::value", tonumber(stdout))
end)
