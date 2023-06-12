-- -------------------------------------------------------------------------- --
-- .---.-.--.--.--.-----.-----.-----.--------.-----.--.--.--.--------.
-- |  _  |  |  |  |  -__|__ --|  _  |        |  -__|  |  |  |        |
-- |___._|________|_____|_____|_____|__|__|__|_____|________|__|__|__|
-- -------------------------------------------------------------------------- --
-- this is where the configuration begins, everything else is loaded from this
-- central point from top to bottom, order matters.
--
-- pcall = if luarocks exists load it (thus access lua dependencies), if not
-- don't trip
pcall(require, "luarocks.loader")
-- -------------------------------------------------------------------------- --
--
-- first the autofocus library is loaded in
require("awful.autofocus")
-- now the theme files and variables bound to the beautiful. namespace
require("themes")
-- helper functions & global functionality
require("utilities")
require("modules")
-- global variable assignment to ease using common libraries, modules, etc.
require("variables")
-- Settings of various builtin options (and some custom layouts)
require("configuration")
-- UI elements (widgets) that the user interacts with
require("ui")
