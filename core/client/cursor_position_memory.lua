---@diagnostic disable: undefined-global
-- https://gist.github.com/JustAPerson/f2aadb7150c852734421aa0662dcc345

local capi = {
    client = client,
    mouse = mouse,
}
local memory = {}

local function client_focus(c)
    -- Return if focusing client under cursor
    if capi.mouse.current_client == c then
        return
    end

    -- Use remembered or default (center) coordinates
    local coords = memory[c]
    if not coords then
        coords = { x = c.width / 2, y = c.height / 2 }
    end
    coords.x = coords.x + c.x
    coords.y = coords.y + c.y
    capi.mouse.coords(coords)
end
local function client_unfocus(c)
    -- If leaving client under mouse, remember relative coords
    if capi.mouse.current_client == c then
        local mcoords = capi.mouse.coords()
        memory[c] = {
            x = mcoords.x - c.x,
            y = mcoords.y - c.y,
        }
        return
    end
    -- Otherwise, clear memory
    memory[c] = nil
end

capi.client.connect_signal("focus", client_focus)
capi.client.connect_signal("unfocus", client_unfocus)
