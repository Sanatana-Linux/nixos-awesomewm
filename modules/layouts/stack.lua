--- Stack layout (deprecated — use mstab instead).
-- Two variants: `stack` (master on left, slaves stacked right) and
-- `stackLeft` (master on right, slaves stacked left). Retained for
-- historical reference.
-- @module modules.layouts.stack

-- Import necessary modules
local math = math
local screen = screen

-- Create a table for the custom layout
local stack = {}

--- Stack arrangement core: master left/right + slaves stacked on the other side.
-- @tparam table p Layout parameters
-- @tparam string dir `"right"` for master-left, `"left"` for master-right
-- @local
local function arrange(p, dir)
    local t = p.tag or screen[p.screen].selected_tag
    local wa = p.workarea
    local cls = p.clients

    -- Check if there are no clients
    if #cls == 0 then
        return
    end

    -- Calculate master and slave dimensions
    local mstrWidthFact = t.master_width_factor
    local mstrWidth = math.floor(wa.width * mstrWidthFact)
    local mstrHeight = math.floor(wa.height)

    local slavesNumber = #cls - 1
    local slavesWidth = math.floor(wa.width - mstrWidth)
    local slavesHeight = math.floor(wa.height)

    -- Adjust master width if there is only one client
    if slavesNumber == 0 then
        mstrWidth = wa.width
    end

    -- Place master window
    local c, g = cls[1], {}

    g.height = math.max(mstrHeight, 1)
    g.width = math.max(mstrWidth, 1)

    g.y = wa.y
    g.x = (dir == "right") and wa.x or (wa.x + slavesWidth)

    -- Adjust position if there are no slaves
    if slavesNumber == 0 then
        g.x = wa.x
    end

    p.geometries[c] = g

    -- Return if there's only one client
    if #cls == 1 then
        return
    end

    -- Place slave windows
    for i = 2, #cls do
        local c, g = cls[i], {}

        g.height = math.max(slavesHeight, 1)
        g.width = math.max(slavesWidth, 1)

        g.y = wa.y
        g.x = (dir == "right") and (wa.x + mstrWidth) or wa.x

        p.geometries[c] = g
    end
end

-- Set the layout name
stack.name = "stack"

--- Arrange clients in right-stack mode (master left).
-- @tparam table p Layout parameters
function stack.arrange(p)
    return arrange(p, "right")
end

-- Create a table for the 'stack' layout with left placement
stack.left = {}

-- Set the layout name for left placement
stack.left.name = "stackLeft"

--- Arrange clients in left-stack mode (master right).
-- @tparam table p Layout parameters
function stack.left.arrange(p)
    return arrange(p, "left")
end

-- Return the 'stack' layout object
return stack
