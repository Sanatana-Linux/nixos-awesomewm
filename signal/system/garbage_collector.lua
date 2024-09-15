local awful = require("awful")
local gears = require("gears")

gears.timer({
	timeout = 5,
	autostart = true,
	call_now = true,
	callback = function()
		collectgarbage("collect")
	end,
})

collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
