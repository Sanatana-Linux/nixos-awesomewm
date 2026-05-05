-- DEPRECATED: use mstab instead, kept for historical purposes
-- based on dovetail and bling's mbox, but without all the extra frills

--  Stack right layout:
--  +-------+------+
--  |       |      |
--  |   1   | 2... |
--  |       |      |
--  +-------+------+
--
--  Stack left layout:
--  +------+-------+
--  |      |       |
--  | 2... |   1   |
--  |      |       |
--  +------+-------+
-- ------------------------------------------------- --

-- Import necessary modules
local math = math
local screen = screen

-- Create a table for the custom layout
local stack = {}

-- Function to arrange clients in the 'stack' layout
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

-- Function to arrange clients in the 'stack' layout with right placement
function stack.arrange(p)
    return arrange(p, "right")
end

-- Create a table for the 'stack' layout with left placement
stack.left = {}

-- Set the layout name for left placement
stack.left.name = "stackLeft"

-- Function to arrange clients in the 'stack' layout with left placement
function stack.left.arrange(p)
    return arrange(p, "left")
end

-- Return the 'stack' layout object
return stack
