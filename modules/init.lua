--[[
  Modules Aggregator (curated subset)

  This file returns a table containing only those modules that are accessed via
  the `modules.<name>` namespaced pattern from UI consumers. Direct callers
  should still use `require("modules.<name>")` to avoid coupling to this aggregator.

  Modules in this table:
    - hover_button: UI button with hover effects (used by notification, battery, control panel)
    - calendar:     Calendar widget (used by day_info_panel)
    - text_input:   Text input widget (used by control panel, launcher)
    - menu:         Custom menu widget (used by desktop context menu)
--]]

return {
    hover_button = require("modules.hover_button"),
    calendar = require("modules.calendar"),
    text_input = require("modules.text_input"),
    menu = require("modules.menu"),
}
