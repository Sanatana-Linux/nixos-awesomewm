-- Import required libraries
local awful = require("awful") -- AwesomeWM core functionality
local capi = { tag = tag } -- Capture global tag API

-- Import custom layout modules (from modules/layouts/ aggregator)
local layouts = require("modules.layouts")
local beautiful = require("beautiful") -- Theme system

-- Configure default layouts when requested by the tag system
capi.tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        -- CUSTOM LAYOUTS (ordered by priority/usefulness)
        layouts.mstab,       -- Master-stack with tabbed secondary windows
        layouts.cascade,     -- Cascading window layout
        layouts.cascade.tile, -- Cascading tile layout (master column + slave cascade)
        layouts.centerwork,  -- Center-focused layout (vertical master, replaces vertical.lua)
        layouts.centerwork.horizontal, -- Center-focused layout (horizontal master, replaces horizon.lua)
        layouts.deck,        -- Stacked layout with custom padding/margins
        layouts.thrizen,     -- Three-column balanced layout
        layouts.equalarea,   -- Equal area distribution among windows
        layouts.termfair,    -- Terminal-friendly fair distribution
        layouts.grid,        -- Floating layout with discrete geometry grid
        layouts.map,         -- Tiling layout with user-defined geometry groups

        -- BUILT-IN LAYOUTS (commented out - available but not used)
        -- awful.layout.suit.max,                 -- Maximized single window
        -- awful.layout.suit.spiral.dwindle,      -- Decreasing spiral
        -- awful.layout.suit.spiral,              -- Standard spiral
        -- awful.layout.suit.fair,                -- Fair distribution
        -- awful.layout.suit.tile,                -- Standard tiling
        -- awful.layout.suit.fair.horizontal,     -- Horizontal fair distribution

        awful.layout.suit.floating, -- Floating windows (always available)

        -- Additional built-in layouts (disabled)
        -- awful.layout.suit.magnifier,           -- Magnified master window

        -- awful.layout.suit.tile.left,           -- Left-side master
        -- awful.layout.suit.tile.right,          -- Right-side master
        -- awful.layout.suit.tile.bottom,         -- Bottom master
        -- awful.layout.suit.tile.top,            -- Top master
        -- awful.layout.suit.max.fullscreen,      -- True fullscreen
        -- awful.layout.suit.corner.nw,           -- Northwest corner master
        -- awful.layout.suit.corner.ne,           -- Northeast corner master
        -- awful.layout.suit.corner.sw,           -- Southwest corner master
        -- awful.layout.suit.corner.se,           -- Southeast corner master
    })
end)

-- Create tags (workspaces) for each screen
awful.screen.connect_for_each_screen(function(s)
    -- Create 5 numbered tags per screen, using the first layout as default
    awful.tag(
        { "A", "W", "E", "S", "O", "M", "E", "W", "M" },
        s,
        awful.layout.layouts[1]
    )
end)
