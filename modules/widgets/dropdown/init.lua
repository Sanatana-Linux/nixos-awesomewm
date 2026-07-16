---@diagnostic disable: undefined-global
--- Dropdown application manager.
-- Toggle-style window spawner for "quaked" applications (terminals,
-- calculators, etc.) that slide in from a screen edge, similar to
-- guake/yaquake. Each registered program has at most one window
-- per screen; subsequent toggles show/hide the existing window.
--
-- @module modules.dropdown
-- @see awful.placement

-- Grab environment
local pairs = pairs
local awful = require("awful")
local setmetatable = setmetatable
local capi = {
    mouse = mouse,
    client = client,
    screen = screen,
}
-- local backdrop = require("modules.backdrop")

-- Dropdown: drop-down applications manager for the awesome window manager

local dropdown = {}

--- Reveal every hidden dropdown window across all programs and screens.
-- Used to recover from tag/monitor reassignments when windows have
-- been "lost" in hidden space.
function dropdown.showall()
    for prog, scrs in pairs(dropdown) do
        for src, c in pairs(scrs) do
            awful.client.movetotag(awful.tag.selected(capi.mouse.screen), c)
            c.hidden = false
            c:raise()
            capi.client.focus = c
        end
    end
end

--- Bind the window currently under the cursor as the dropdown for `prog`.
-- On next `toggle(prog, ...)`, the existing window will be reused
-- instead of spawning a new one.
-- @tparam string prog Program key (the spawn command)
function dropdown.attach(prog)
    if not dropdown[prog] then
        dropdown[prog] = {}
    end

    screen = capi.mouse.screen
    c = awful.mouse.client_under_pointer()
    dropdown[prog][screen] = c
end

--- Spawn (or toggle) a dropdown window for `prog`.
-- First call spawns the program and registers a manage-signal handler
-- to position the window. Subsequent calls hide or show the existing
-- window — sliding in from the configured edge.
-- @tparam string prog Program/command to spawn
-- @tparam[opt="top"] string vert Vertical placement: "top" | "center" | "bottom"
-- @tparam[opt="center"] string horiz Horizontal placement: "left" | "center" | "right"
-- @tparam[opt=1] number width Absolute pixels, or fraction of screen (0..1)
-- @tparam[opt=0.25] number height Absolute pixels, or fraction of screen (0..1)
-- @tparam[opt=false] boolean sticky Whether the dropdown is visible on all tags
-- @tparam[opt=nil] number screen Screen index (defaults to mouse screen)
function dropdown.toggle(prog, vert, horiz, width, height, sticky, screen)
    vert = vert or "top"
    horiz = horiz or "center"
    width = width or 1
    height = height or 0.25
    sticky = sticky or false
    screen = screen or capi.mouse.screen

    -- Determine signal usage in this version of awesome
    local attach_signal = capi.client.connect_signal or capi.client.add_signal
    local detach_signal = capi.client.disconnect_signal
        or capi.client.remove_signal

    if not dropdown[prog] then
        dropdown[prog] = {}

        -- Add unmanage signal for Dropdown programs
        attach_signal("unmanage", function(c)
            for scr, cl in pairs(dropdown[prog]) do
                if cl == c then
                    dropdown[prog][scr] = nil
                end
            end
        end)
    end

    if not dropdown[prog][screen] then
        -- Create a unique identifier for this dropdown instance
        local dropdown_id = prog
            .. "_dropdown_"
            .. tostring(os.time())
            .. "_"
            .. tostring(screen)

        spawnw = function(c)
            -- More specific client identification to prevent wrong windows from being captured
            -- Check if this client matches the program we're expecting
            if not (c.class and c.class:lower():find(prog:lower())) then
                return -- This client doesn't match our program, ignore it
            end

            -- Check if we already have a dropdown for this prog/screen combination
            if dropdown[prog][screen] then
                return -- Already have a dropdown, ignore this client
            end

            dropdown[prog][screen] = c
            -- Mark this client as a dropdown with our unique ID
            c._dropdown_id = dropdown_id

            -- backdrop.show()

            -- Dropdown clients are floaters
            c.floating = true
            -- Client geometry and placement
            local screengeom = capi.screen[screen].workarea

            if width <= 1 then
                width = math.ceil(screengeom.width * width) - 3
            end
            if height <= 1 then
                height = math.ceil(screengeom.height * height)
            end

            if horiz == "left" then
                x = screengeom.x
            elseif horiz == "right" then
                x = screengeom.width - width
            else
                x = screengeom.x + math.ceil((screengeom.width - width) / 2) - 1
            end

            if vert == "bottom" then
                y = screengeom.height + screengeom.y - height
            elseif vert == "center" then
                y = screengeom.y + math.ceil((screengeom.height - height) / 2)
            else
                y = screengeom.y
            end

            -- Client properties
            c:geometry({ x = x, y = y, width = width, height = height })
            c.above = true
            c.skip_taskbar = false
            if sticky then
                c.sticky = true
            end
            if c.titlebar then
                awful.titlebar.remove(c)
            end

            c:raise()
            capi.client.focus = c
            detach_signal("manage", spawnw)
        end

        -- Add manage signal and spawn the program
        attach_signal("manage", spawnw)
        awful.spawn.with_shell(prog, false)
    else
        -- Get a running client
        c = dropdown[prog][screen]

        status, err =
            pcall(awful.client.movetotag, awful.tag.selected(screen), c)
        if err then
            dropdown[prog][screen] = false
            return
        end

        -- Switch the client to the current workspace
        if c:isvisible() == false then
            c.hidden = true
            awful.client.movetotag(awful.tag.selected(screen), c)
        end

        -- Focus and raise if hidden
        if c.hidden then
            -- Make sure it is centered
            if vert == "center" then
                awful.placement.center_vertical(c)
            end
            if horiz == "center" then
                awful.placement.center_horizontal(c)
            end
            c.hidden = false
            c:raise()
            capi.client.focus = c
            -- backdrop.show()
        else -- Hide and detach tags if not
            c.hidden = true
            local ctags = c:tags()
            for i, t in pairs(ctags) do
                ctags[i] = nil
            end
            c:tags(ctags)
            -- backdrop.hide()
        end
    end
end

return dropdown
