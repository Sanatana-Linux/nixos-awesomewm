--   +---------------------------------------------------------------+
--        .---.-.--.--.--.-----.-----.-----.--------.-----.
--        |  _  |  |  |  |  -__|__ --|  _  |        |  -__|
--        |___._|________|_____|_____|_____|__|__|__|_____|
--   +---------------------------------------------------------------+
-- central point from top to bottom, order matters.
--
-- if luarocks exists load it, if not don't trip
pcall(require, "luarocks.loader")

--   +---------------------------------------------------------------+
-- first the autofocus library is loaded in
require("awful.autofocus")
--   +---------------------------------------------------------------+
-- NOTE: See sub-directory README files for more info

-- now the theme files and variables bound to the beautiful. namespace
require("themes")
-- helper functions
require("utilities")
-- locally-derived back-end functionality
require("modules")
-- Settings of various builtin options (and some custom layouts)
--  with globally scoped variables
require("configuration")
-- UI elements (widgets) that the user interacts with
require("widgets")

--   +---------------------------------------------------------------+
--                            ___ __
--                          .'  _|__|.-----.
--                          |   _|  ||     |
--                          |__| |__||__|__|
--   +---------------------------------------------------------------+
