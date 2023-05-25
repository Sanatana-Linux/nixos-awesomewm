--  ______         __   __
-- |   __ \.---.-.|  |_|  |_.-----.----.--.--.
-- |   __ <|  _  ||   _|   _|  -__|   _|  |  |
-- |______/|___._||____|____|_____|__| |___  |
--                                     |_____|
--  _______ __                     __
-- |     __|__|.-----.-----.---.-.|  |
-- |__     |  ||  _  |     |  _  ||  |
-- |_______|__||___  |__|__|___._||__|
--             |_____|
-- ------------------------------------------------- --
-- signal::battery
--      percentage
--      state
local upower_widget = require('utilities.battery')
local battery_listener = upower_widget({
	device_path = '/org/freedesktop/UPower/devices/battery_BAT0',
	instant_update = true,
})

battery_listener:connect_signal('upower::update', function(_, device)
	if device ~= nil then
		awesome.emit_signal('signal::battery', device.percentage, device.state)
		collectgarbage('collect')
	else
		awesome.emit_signal('signal::battery:error')
	end
end)
-- ------------------------------------------------- --
