local gears = require("gears")
local beautiful = require("beautiful")

-- ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
--

require("helpers")
-- run autostart script
require("main.autostart")

-- ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
--
-- run setup
require("setup"):generate()

-- ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
--
-- initialize the theme
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme/init.lua")
require("main")
require("awful.autofocus")

-- ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
--
-- init widget
require("misc")
require("ui")
require("signal")
