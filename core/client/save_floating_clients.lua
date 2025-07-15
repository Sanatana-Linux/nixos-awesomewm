---@diagnostic disable: undefined-global
local awful = require("awful")

-- Calculates geometry (position and size) relative to the screen.
-- This allows restoring to the correct proportional position on different screens/resolutions.
local function rel(screen, win)
    return {
        x = (win.x - screen.x) / screen.width,
        y = (win.y - screen.y) / screen.height,
        width = win.width / screen.width,
        height = win.height / screen.height, -- Store height ratio directly
    }
end

-- Calculates absolute geometry from the stored relative values and current screen.
local function unrel(s, rel)
    return rel
        and {
            x = s.x + s.width * rel.x,
            y = s.y + s.height * rel.y,
            width = s.width * rel.width,
            height = s.height * rel.height, -- Use stored height ratio
        }
end

local stored = {}
local floating_layout = awful.layout.suit.floating

-- Remove a client's stored geometry when it is closed.
local function forget(c)
    stored[c.window] = nil
end

-- Store a client's geometry if it is floating.
---@diagnostic disable-next-line: lowercase-global
function remember(c)
    -- Only store geometry if the client is actually floating.
    if c.floating then
        stored[c.window] = rel(c.screen.geometry, c:geometry())
    end
end

-- Restore a client's last known floating geometry.
---@diagnostic disable-next-line: lowercase-global
function restore(c)
    local s = stored[c.window]
    if s then
        c:geometry(unrel(c.screen.geometry, s))
        return true
    else
        return false
    end
end

-- A client can become floating in multiple ways (e.g. toggling, layout change).
-- This function ensures we restore its position if it becomes floating.
local function restore_and_remember(c)
    -- If the client is now floating...
    if c.floating then
        -- ...and we have a stored position for it, restore it.
        restore(c)
    end
    -- Always update the stored position when geometry changes on a floating client.
    remember(c)
end

-- When a client is first managed, store its initial floating geometry if applicable.
client.connect_signal("manage", remember)

-- When a client's floating state changes, update or restore its position.
client.connect_signal("property::floating", restore_and_remember)

-- When a client is closed, forget its stored position.
client.connect_signal("unmanage", forget)

-- When the layout for a tag changes...
tag.connect_signal("property::layout", function(t)
    -- ...and the new layout is the floating layout...
    if awful.layout.get(t.screen) == floating_layout then
        -- ...iterate over all clients on that tag and restore their floating positions.
        for _, c in ipairs(t:clients()) do
            restore(c)
        end
    end
end)

return restore