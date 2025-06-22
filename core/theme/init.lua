local beautiful = require("beautiful")
local gfs = require("gears.filesystem")
local user = require("user")

local themes = {
	["yerba_buena"] = true
}

local theme_name = themes[user.theme] and user.theme or "yerba_buena"
beautiful.init(gfs.get_configuration_dir() .. "themes/" .. theme_name .. "/theme.lua")
