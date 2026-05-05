-- NOTE: also courtesy of bling
--
-- NOTE: this layout shows the upper right corner of
-- clients out of focus like a poker hand or deck of
-- playing cards
-- ------------------------------------------------- --

-- Create a table for the custom layout
local deck = {}

-- Set the name of the custom layout to 'deck'
deck.name = "deck"

-- Function to arrange clients in the 'deck' layout
function deck.arrange(p)
    local area = p.workarea
    local t = p.tag or screen[p.screen].selected_tag
    local client_count = #p.clients

    -- Handle the case when there is only one client
    if client_count == 1 then
        local c = p.clients[1]
        local g = {
            x = area.x,
            y = area.y,
            width = area.width,
            height = area.height,
        }
        p.geometries[c] = g
        return
    end

    -- Calculate offsets for positioning clients in the 'deck' layout
    local xoffset = area.width * 0.1 / (client_count - 1)
    local yoffset = area.height * 0.1 / (client_count - 1)

    -- Iterate through clients and set their geometries
    for idx = 1, client_count do
        local c = p.clients[idx]
        local g = {
            x = area.x + (idx - 1) * xoffset,
            y = area.y + (idx - 1) * yoffset,
            width = area.width - (xoffset * (client_count - 1)),
            height = area.height - (yoffset * (client_count - 1)),
        }
        p.geometries[c] = g
    end
end

-- Return the 'deck' layout table
return deck
