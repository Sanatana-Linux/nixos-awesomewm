local upower_widget = require("modules.battery")
local battery_listener = upower_widget({
  device_path = "/org/freedesktop/UPower/devices/battery_BAT0",
  instant_update = true,
})

battery_listener:connect_signal("upower::update", function(_, device)
  if device ~= nil then
    awesome.emit_signal("signal::battery", device.percentage, device.state)
    collectgarbage("collect")
  else
    awesome.emit_signal("signal::battery:error")
  end
end)
