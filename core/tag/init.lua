-- Import required libraries
local awful = require("awful") -- AwesomeWM core functionality
local capi = { tag = tag }     -- Capture global tag API

-- Import custom layout modules
local center = require("core.tag.layouts.center")       -- Center layout for focused windows
local thrizen = require("core.tag.layouts.thrizen")     -- Three-column layout
local horizon = require("core.tag.layouts.horizon")     -- Horizontal split layout
local equalarea = require("core.tag.layouts.equalarea") -- Equal area distribution layout
local deck = require("core.tag.layouts.deck")           -- Deck/stacked layout with specific padding
local mstab = require("core.tag.layouts.mstab")         -- Master-stack tabbed layout
local cascade = require("core.tag.layouts.cascade")     -- Cascading window layout
local beautiful = require("beautiful")                  -- Theme system

-- Configure default layouts when requested by the tag system
capi.tag.connect_signal("request::default_layouts", function()
        awful.layout.append_default_layouts {
                -- CUSTOM LAYOUTS (ordered by priority/usefulness)
                mstab,        -- Master-stack with tabbed secondary windows
                cascade.tile, -- Tiled cascade variant
                deck,         -- Stacked layout with custom padding/margins
                cascade,      -- Standard cascading windows
                center,       -- Centered master window layout
                thrizen,      -- Three-column balanced layout
                horizon,      -- Horizontal master/stack split
                equalarea,    -- Equal area distribution among windows

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
        }
end)

-- Create tags (workspaces) for each screen
awful.screen.connect_for_each_screen(function(s)
        -- Create 5 numbered tags per screen, using the first layout as default
        awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])
end)
