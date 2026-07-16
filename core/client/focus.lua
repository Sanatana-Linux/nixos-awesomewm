--- Client focus management.
-- Sloppy focus (activate under pointer), debounced focus timer,
-- focus-back on minimize/unmanage, and slave-client assignment.
-- @module core.client.focus

local awful = require("awful")
local gears = require("gears")
local capi = { client = client, mouse = mouse, tag = tag }

--- Activate the client under the mouse pointer (sloppy focus).
-- Used by `mouse::enter` and debounced via `focus_timer`.
local function activate_under_pointer()
    local c = capi.mouse.current_client
    if c then
        c:activate({ context = "mouse_enter", raise = false })
    end
end

local focus_timer = gears.timer({
    autostart = true,
    timeout = 0.2,
    single_shot = true,
    callback = activate_under_pointer,
})

--- Debounced focus timer.
-- When a tag switches or a client is unmanaged, wait 300ms then
-- activate whichever client is under the pointer (sloppy-focus style).
local function start_focus_timer()
    -- Buffer by 0.3s to avoid colliding with the autostart's 0.2s window
    gears.timer({
        timeout = 0.3,
        single_shot = true,
        autostart = true,
        callback = function()
            focus_timer:start()
        end,
    })
end

--- Handle `property::tags` signal — restart focus timer for
-- non-floating clients when tag membership changes.
-- @tparam client c
local function handle_tags_change(c)
    if not c.floating then
        start_focus_timer()
    end
end

--- Handle `manage` signal — mark tiled clients as slaves so
-- they don't steal focus from their transient parent.
-- @tparam client c
local function handle_manage_focus(c)
    if not c.floating then
        awful.client.setslave(c)
    end
end

--- Move focus/mouse to the last-focused client when a client is
-- minimized or unmanaged, or when the tag selection changes.
local function focus_back()
    local s = awful.screen.focused()
    local c = awful.client.focus.history.get(s, 0)
    if c and c.valid then
        local geo = c:geometry()
        capi.mouse.coords({
            x = geo.x + geo.width / 2,
            y = geo.y + geo.height / 2,
        })
        c:activate({ context = "key.unminimize", raise = false })
    end
end

return {
    activate_under_pointer = activate_under_pointer,
    start_focus_timer = start_focus_timer,
    handle_tags_change = handle_tags_change,
    handle_manage_focus = handle_manage_focus,
    focus_back = focus_back,
}
