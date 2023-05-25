local gears = require('gears')
local awful = require('awful')

local cmd = [[sh -c df -kh -B 1GB /dev/sda3 | tail -1 | awk '{printf "%d@%d", $4, $3}' | cut -c1-2]]

gears.timer({
	timeout = 120,
	call_now = true,
	autostart = true,
	callback = function()
		awful.spawn.easy_async_with_shell(cmd, function(usage) awesome.emit_signal('disk::usage', usage) end)
	end,
})
