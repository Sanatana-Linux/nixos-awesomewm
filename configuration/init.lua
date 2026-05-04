-- Core AwesomeWM configuration entry point.
-- This file loads all core modules required for basic functionality.
-- Each require statement loads a specific aspect of the configuration:
--   - autostart: Handles applications and scripts to run on startup
--   - theme: Theme and appearance settings
--   - tag: Virtual desktop (tag) management
--   - client: Window (client) management rules and signals
--   - keybind: Global and client keybindings
--   - screen: Screen management and primary screen override

require("configuration.autostart")
require("configuration.theme")
require("configuration.tag")
require("configuration.client")
require("configuration.keybind")
require("configuration.screen")
