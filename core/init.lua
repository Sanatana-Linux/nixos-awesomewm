--- Core AwesomeWM configuration entry point.
-- Loads submodules in dependency-safe order:
--   1. autostart — launch startup apps + garbage collection
--   2. theme    — `beautiful.init()` (every downstream module reads theme vars)
--   3. tag      — tag names + layout rotation
--   4. client   — window rules, signals, resize helpers, restore
--   5. screen   — primary-screen selection + workarea padding
-- @module core

require("core.autostart")
require("core.theme")
require("core.tag")
require("core.client")
require("core.screen")
