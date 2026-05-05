--[[
  Layout Module

  Aggregator for all custom tiling layouts.
  Each layout returns a table with `name` and `arrange(p)` for use with
  `awful.layout.suit`.

  Loaded via `require("modules.layouts")` which returns a flat table
  keyed by layout name for easy access.
--]]

return {
  -- Configuration's existing custom layouts
  mstab      = require("modules.layouts.mstab"),      -- Master-stack with tabbed slaves
  deck       = require("modules.layouts.deck"),       -- Cascading deck of cards
  thrizen    = require("modules.layouts.thrizen"),    -- 3-column balanced grid
  equalarea  = require("modules.layouts.equalarea"),  -- Equal area BSP distribution
  stack      = require("modules.layouts.stack"),      -- Deprecated, kept for reference

  -- External layouts adapted from lib.layouts
  cascade    = require("modules.layouts.cascade"),    -- Cascading window layout (also has .tile variant)
  centerwork = require("modules.layouts.centerwork"), -- Center-focused layout (vertical master)
  termfair   = require("modules.layouts.termfair"),   -- Terminal-friendly fair layout
  grid       = require("modules.layouts.grid"),       -- Floating layout with discrete geometry grid
  map        = require("modules.layouts.map"),        -- Tiling layout with user-defined geometry groups
}
