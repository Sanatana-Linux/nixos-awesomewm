-- Core AwesomeWM configuration entry point.
-- This file loads all core modules required for basic functionality.
-- Each require statement loads a specific aspect of the configuration:
--   - autostart: Handles applications and scripts to run on startup
--   - error: Error handling and notifications
--   - theme: Theme and appearance settings
--   - notification: Notification system configuration
--   - tag: Virtual desktop (tag) management
--   - client: Window (client) management rules and signals
--   - keybind: Global and client keybindings

require("core.autostart")
require("core.error")
require("core.theme")
require("core.notification")
require("core.tag")
require("core.client")
require("core.keybind")
