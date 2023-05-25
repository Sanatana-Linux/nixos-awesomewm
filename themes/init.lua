local beautiful = require('beautiful')
local gears = require('gears')

local function load_theme() beautiful.init(gears.filesystem.get_configuration_dir() .. 'themes/theme.lua') end
return {
	load_theme(),
}
