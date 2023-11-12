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
-- NOTE: See sub-directory README files for more info on their contents

-- The theme files and variables bound to the `beautiful.` namespace
require("themes")
-- Helper functions at the `utilities.` namespace
require("utilities")
-- Locally-derived back-end functionality
require("modules")
-- Settings of various builtin options (and some custom layouts)
--  with globally scoped variables
require("configuration")
-- Event watching functionality
require("signal")
-- UI elements (widgets) that the user interacts with
require("ui")
