local awful = require("awful")

local autostart = {

"xrdb -merge ~/.Xresources &",
"xsettingsd",
    "xfsettingsd &",
    "picom --config $HOME/.config/picom/picom.conf &",
    "mkdir -p ~/.cache/awesome/json &"
}

local function restarted()
	awesome.register_xproperty("restarted", "boolean")
	local detected = awesome.get_xproperty("restarted") ~= nil
	awesome.set_xproperty("restarted", true)
	return detected
end

local function autostarter()
if not restarted() then
	for _, command in ipairs(autostart) do
		require("awful").spawn.easy_async({ 'pkill', '--full', '--uid', os.getenv('USER'), '^' .. command }, function()
			require("awful").spawn.easy_async_with_shell(command, function() end) -- func needed to avoid callback error
		end)
	end

end

end

autostarter()

