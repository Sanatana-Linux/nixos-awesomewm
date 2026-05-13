--[[
  Layout Module

  Aggregator for all custom tiling layouts.
  Each layout returns a table with `name` and `arrange(p)` for use with
  `awful.layout.suit`.

  After building the table, registers handlers and tips with common.lua
  (done here to avoid circular deps — common.lua can't require us and vice versa).
--]]

local layouts = {
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

-- Register custom layout handlers/tips with common
-- Must happen here to avoid circular dependency: init -> grid -> common -> init
local common = require("modules.layouts.common")
if common.register_custom_layouts then
    common.register_custom_layouts(layouts)
end

return layouts
