                                                                   
-- .---.-.--.--.--.-----.-----.-----.--------.-----.--.--.--.--------.
-- |  _  |  |  |  |  -__|__ --|  _  |        |  -__|  |  |  |        |
-- |___._|________|_____|_____|_____|__|__|__|_____|________|__|__|__|
                                                                   
-- -------------------------------------------------------------------------- --
-- if luarocks exists load it, if not don't trip
-- 
pcall(require, "luarocks.loader")
-- -------------------------------------------------------------------------- --
-- 
require("awful.autofocus")
require("themes")
require ("utilities")
require("variables")
require("signal.global")
require("configuration")
require("ui")
