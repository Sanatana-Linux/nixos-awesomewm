-- https://gist.github.com/JustAPerson/f2aadb7150c852734421aa0662dcc345

local awful = require("awful")
local capi = {
    client = client,
    mouse = mouse,
}
local memory = {}

local function client_focus(c)
    -- do nothing if focusing client under cursor
    if capi.mouse.current_client == c then
        return
    end

    -- move mouse either to memory or centered over window
    local coords = memory[c] or { x = c.width / 2, y = c.height / 2 }
    coords.x = coords.x + c.x
    coords.y = coords.y + c.y
    capi.mouse.coords(coords)
end

local function client_unfocus(c)
    -- are we leaving the client under the mouse
    if capi.mouse.current_client == c then
        -- yes then remember the relative coords
        mcoords = capi.mouse.coords()
        memory[c] = {
            x = mcoords.x - c.x,
            y = mcoords.y - c.y,
        }
    else
        -- no then we've already moved the mouse off this window so
        -- we should clear memory
        memory[c] = nil
    end
end
capi.client.connect_signal("focus", client_focus)
capi.client.connect_signal("unfocus", client_unfocus)
