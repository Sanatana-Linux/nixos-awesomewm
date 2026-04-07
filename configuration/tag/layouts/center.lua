-- NOTE: Adapted from https://github.com/kotbaton/awesomewm-config
--
-- NOTE: The nelow demonstrates the tiling arrangement
-- provided by this file
--    +---+-----+---+
--    | 5 |     | 2 |
--    |   |     +---+
--    +---+  1  | 3 |
--    |   |     +---+
--    | 6 |     | 4 |
--    +---+-----+---+

-- Import necessary modules
local math = math
local screen = screen
local awful = require("awful")

-- Define a custom layout object named 'center'
local center = {}

-- Function to arrange clients in a centered layout
function center.arrange(p)
    local area = p.workarea
    local t = p.tag or screen[p.screen].selected_tag
    local mwfact = t.master_width_factor
    local nmaster = math.min(t.master_count, #p.clients)
    local nslaves = #p.clients - nmaster

    -- Calculate dimensions for master and slave areas
    local master_area_width = area.width * mwfact
    local slave_area_width = area.width - master_area_width
    local master_area_x = area.x + 0.5 * slave_area_width

    -- Calculate the number of slaves on each side
    local number_of_left_sided_slaves = math.floor(nslaves / 2)
    local number_of_right_sided_slaves = nslaves - number_of_left_sided_slaves

    -- Initialize iterators for left and right slaves
    local left_iterator = 0
    local right_iterator = 0

    -- Special cases
    if t.master_count == 0 then
        -- No masters, fall back to awesome's fair layout
        awful.layout.suit.fair.arrange(p)
        return
    end

    if nslaves == 1 then
        -- Only one slave, fall back to awesome's master-stack tile layout
        awful.layout.suit.tile.right.arrange(p)
        return
    end

    if nslaves < 1 then
        -- No slaves, fullscreen master area
        master_area_width = area.width
        master_area_x = area.x
    end

    -- Arrange masters in vertical stack in center area
    for idx = 1, nmaster do
        local c = p.clients[idx]
        if c then -- Validate client exists
            local g = {
                x = master_area_x,
                y = area.y + (idx - 1) * (area.height / nmaster), -- Fixed: was (nmaster - idx)
                width = master_area_width,
                height = area.height / nmaster,
            }
            p.geometries[c] = g
        end
    end

    -- Arrange slaves on left and right sides alternating
    for idx = 1, nslaves do
        local c = p.clients[idx + nmaster]
        if not c then -- Validate client exists
            break
        end
        
        local g
        
        -- Alternate between left (odd indices) and right (even indices)
        if idx % 2 == 1 then
            -- Odd index (1,3,5...), place on the left side
            g = {
                x = area.x,
                y = area.y
                    + left_iterator
                        * (area.height / number_of_left_sided_slaves),
                width = slave_area_width / 2,
                height = area.height / number_of_left_sided_slaves,
            }
            left_iterator = left_iterator + 1
        else
            -- Even index (2,4,6...), place on the right side
            g = {
                x = area.x + master_area_width + slave_area_width / 2,
                y = area.y
                    + right_iterator
                        * (area.height / number_of_right_sided_slaves),
                width = slave_area_width / 2,
                height = area.height / number_of_right_sided_slaves,
            }
            right_iterator = right_iterator + 1
        end

        p.geometries[c] = g
    end
end

-- Set the name of the custom layout to 'center'
center.name = "center"

-- Return the 'center' layout object
return center
