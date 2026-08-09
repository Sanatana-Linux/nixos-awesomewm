---@diagnostic disable: undefined-global
--- Scratchpad client manager.
-- A single-slot buffer for parking any client out of the way.
-- `add` parks the focused client — detaches it from all tags and hides
-- it; `toggle` re-attaches it to the currently selected tag, or hides
-- it again. Modeled on the dropdown module's hide/show mechanics, but
-- for arbitrary clients instead of spawned programs.
-- @module core.client.scratchpad

local awful = require("awful")

local capi = { client = client, mouse = mouse }

-- The parked client, or nil when the buffer is empty.
local scratchpad_client = nil

-- Clear the buffer when the parked client is closed.
capi.client.connect_signal("unmanage", function(c)
    if c == scratchpad_client then
        scratchpad_client = nil
    end
end)

--- Park a client in the scratchpad buffer.
-- Replaces any previously parked client. The client is hidden and
-- detached from all tags until `toggle` brings it back.
-- @tparam[opt] client c Client to park (defaults to the focused client)
local function add(c)
    c = c or capi.client.focus
    if not (c and c.valid) then
        return
    end

    if
        scratchpad_client
        and scratchpad_client.valid
        and scratchpad_client ~= c
    then
        scratchpad_client = nil
    end
    scratchpad_client = c

    c.floating = true
    c.hidden = true
    c:tags({})
end

--- Toggle the parked client's visibility on the current tag.
local function toggle()
    local c = scratchpad_client
    if not (c and c.valid) then
        scratchpad_client = nil
        return
    end

    if c.hidden or not c:isvisible() then
        -- Show: move to the mouse screen's selected tag and focus it.
        awful.client.movetotag(awful.tag.selected(capi.mouse.screen), c)
        c.hidden = false
        c:raise()
        capi.client.focus = c
    else
        -- Hide: detach from tags and mark hidden.
        c.hidden = true
        c:tags({})
        if capi.client.focus == c then
            local prev = awful.client.focus.history.previous(c)
            if prev and prev.valid then
                prev:activate({ context = "key.scratchpad", raise = false })
            end
        end
    end
end

return {
    add = add,
    toggle = toggle,
}
