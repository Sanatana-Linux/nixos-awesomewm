--- Theme bootstrap.
-- Calls `beautiful.init()` with the active theme. This is the single point
-- where the theme is selected — change `theme_name` to switch.
-- Loaded first in `configuration/init.lua` because every other module reads
-- theme variables from `beautiful`.
-- @module core.theme

local beautiful = require("beautiful")
local gfs = require("gears.filesystem")

-- Change this to make your own theme
local theme_name = "kailash"
beautiful.init(
    gfs.get_configuration_dir() .. "themes/" .. theme_name .. "/theme.lua"
)
