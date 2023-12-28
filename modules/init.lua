return {
  --   +---------------------------------------------------------------+
  -- modules that are run when this file is invoked during startup and thus initialized
  require(... .. ".autostart"),
  --   +---------------------------------------------------------------+
  -- returned modules that can be invoked as globally scoped functions afterwards when prefixed with `modules.`
  effects = require(... .. ".effects"),
  battery = require(... .. ".battery"),
  dropdown = require(... .. ".dropdown"),
  icon_theme = require("modules.icon_theme"),
  overflow = require(... .. ".overflow"),
  screenshot = require(... .. ".screenshot"),
  sfx = require(... .. ".sfx"),
  snap_edge = require(... .. ".snap_edge"),
}
