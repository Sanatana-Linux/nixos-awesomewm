-- NOTE: creates row for each client, master is largest and at the top
-- ------------------------------------------------- --
-- Import necessary modules
local pairs = pairs

-- Create a table for the custom layout
local horizon = { name = "horizon" }

-- Function to arrange clients in the 'horizon' layout
function horizon.arrange(p)
    local area = p.workarea
    local t = p.tag or screen[p.screen].selected_tag
    local mwfact = t.master_width_factor
    local nmaster = math.min(t.master_count, #p.clients)
    local nslaves = #p.clients - nmaster

    local master_area_height = area.height * mwfact
    local slave_area_height = area.height - master_area_height

    -- Handle special cases: no slaves or no masters
    if nslaves == 0 then
        master_area_height = area.height
        slave_area_height = 0
    end

    if nmaster == 0 then
        master_area_height = 0
        slave_area_height = area.height
    end

    -- Arrange master windows
    for idx = 1, nmaster do
        local c = p.clients[idx]
        local g = {
            x = area.x + (idx - 1) * (area.width / nmaster),
            y = area.y,
            width = area.width / nmaster,
            height = master_area_height,
        }
        p.geometries[c] = g
    end

    -- Arrange slave windows
    for idx = 1, nslaves do
        local c = p.clients[idx + nmaster]
        local g = {
            x = area.x,
            y = area.y
                + master_area_height
                + (idx - 1) * (slave_area_height / nslaves),
            width = area.width,
            height = slave_area_height / nslaves,
        }
        p.geometries[c] = g
    end
end

-- Return the 'horizon' layout object
return horizon
