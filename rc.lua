                                                                   
-- .---.-.--.--.--.-----.-----.-----.--------.-----.--.--.--.--------.
-- |  _  |  |  |  |  -__|__ --|  _  |        |  -__|  |  |  |        |
-- |___._|________|_____|_____|_____|__|__|__|_____|________|__|__|__|
                                                                   
-- -------------------------------------------------------------------------- --
-- if luarocks exists load it, if not don't trip
-- 
pcall(require, 'libraries.luajit.bin.activate')
pcall(require, 'libraries.luajit.bin.lua')
pcall(require, "libraries.luajit.bin.luarocks.loader")
pcall(require, 'libraries.luajit.bin.luarocks')
-- -------------------------------------------------------------------------- --
-- 
require("awful.autofocus")
require("themes")
require ("utilities")
require("variables")
require("signal.global")
require("configuration")
require("ui")
