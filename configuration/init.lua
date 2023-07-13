--  ______               ___ __                          __   __
-- |      |.-----.-----.'  _|__|.-----.--.--.----.---.-.|  |_|__|.-----.-----.
-- |   ---||  _  |     |   _|  ||  _  |  |  |   _|  _  ||   _|  ||  _  |     |
-- |______||_____|__|__|__| |__||___  |_____|__| |___._||____|__||_____|__|__|
--                              |_____|
--   +---------------------------------------------------------------+
-- global variable scoping of everything possibly useful (goes first)
require("configuration.variables")

-- usual stuff after
require("configuration.layout")
require("configuration.mousebindings")
require("configuration.keybindings")
require("configuration.rules")
require("configuration.monitor")
--   +---------------------------------------------------------------+
-- this is being run as a function, hence the (), starting the timer for garbage collection
require("configuration.garbage_collection")()
