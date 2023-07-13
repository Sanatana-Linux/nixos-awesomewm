return {
  --   +---------------------------------------------------------------+
  -- modules that are run when this file is invoked during startup and thus initialized
  require(... .. ".autostart"),
  require(... .. ".floating-clients"),
  require(... .. ".autofocus"),
  require(... .. ".better-resize"),
  --   +---------------------------------------------------------------+
  -- returned modules that can be invoked as globally scoped functions afterwards when prefixed with `modules.`
  effects = require(... .. ".effects"),
  battery = require(... .. ".battery"),
  dropdown = require(... .. ".dropdown"),
  filesystem = require(... .. ".filesystem"),
  icon_theme = require("modules.icon_theme"),
  overflow = require(... .. ".overflow"),
  screenshot = require(... .. ".screenshot"),
  snap_edge = require(... .. ".snap_edge"),
}
