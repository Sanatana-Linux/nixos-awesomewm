--  __   __
-- |  |_|  |--.-----.--------.-----.
-- |   _|     |  -__|        |  -__|
-- |____|__|__|_____|__|__|__|_____|
--  __                   __ __ __
-- |  |--.---.-.-----.--|  |  |__|.-----.-----.
-- |     |  _  |     |  _  |  |  ||     |  _  |
-- |__|__|___._|__|__|_____|__|__||__|__|___  |
--                                      |_____|
-- ----------------------------------------------------------- --
local beautiful = require("beautiful")
local gears = require("gears")

local function load_theme() beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua") end

load_theme()
