--- Deck / cards layout.
-- Shows clients as a cascading deck of cards, each offset slightly from the
-- previous, so the upper-right corner of each underlying client is visible.
-- @module modules.layouts.deck

local deck = {}

-- Set the name of the custom layout to 'deck'
deck.name = "deck"

--- Deck arrange: offset each client diagonally so earlier ones peek out.
-- @tparam table p Layout parameters
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
