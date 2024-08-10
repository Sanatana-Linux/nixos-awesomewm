--  _______              __
-- |     __|.---.-.----.|  |--.---.-.-----.-----.
-- |    |  ||  _  |   _||  _  |  _  |  _  |  -__|
-- |_______||___._|__|  |_____|___._|___  |_____|
--                                  |_____|
-- -------------------------------------------------------------------------- --
return function()
    --- For lower memory consumption at the expense of *some* CPU cycles


--- Enable for lower memory consumption
collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
gears.timer({
	timeout = 5,
	autostart = true,
	call_now = true,
	callback = function()
		collectgarbage("collect")
	end,
})

end
