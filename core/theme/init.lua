local beautiful = require("beautiful")
local gfs = require("gears.filesystem")

-- Change this to make your own theme
local theme_name = "yerba_buena"
beautiful.init(
    gfs.get_configuration_dir() .. "themes/" .. theme_name .. "/theme.lua"
)
