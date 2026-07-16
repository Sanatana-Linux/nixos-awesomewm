--- Modules Aggregator (curated subset).
-- Returns a table containing only those modules that are accessed via
-- the `modules.<name>` namespaced pattern from UI consumers. Direct callers
-- should still use `require("modules.<name>")` to avoid coupling to this aggregator.
--
-- Currently exported: `hover_button`, `calendar`, `text_input`, `menu`.
-- @module modules

return {
    hover_button = require("modules.widgets.hover_button"),
    calendar = require("modules.widgets.calendar"),
    text_input = require("modules.widgets.text_input"),
    menu = require("modules.widgets.menu"),
}
