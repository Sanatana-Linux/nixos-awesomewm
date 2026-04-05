---@diagnostic disable: undefined-global
-- Import AwesomeWM core functionality
local awful = require("awful")
-- Capture global APIs for awesome and client management
local capi = { awesome = awesome, client = client }

-- Modkey is defined globally in core/keybind/init.lua
local modkey = "Mod4" -- Super/Windows key modifier

-- Register global keybindings for tag (workspace) management
awful.keyboard.append_global_keybindings({

    -- TAG NAVIGATION KEYBINDINGS --
    -- Mod4 + Left Arrow: View previous tag in sequence
    awful.key(
        { modkey },
        "Left",
        awful.tag.viewprev,
        { description = "View Previous Tag", group = "Tags" }
    ),

    -- Mod4 + Right Arrow: View next tag in sequence
    awful.key(
        { modkey },
        "Right",
        awful.tag.viewnext,
        { description = "View Next Tag", group = "Tags" }
    ),

    -- Mod4 + Escape: Go back to the previously viewed tag(s)
    awful.key(
        { modkey },
        "Escape",
        awful.tag.history.restore,
        { description = "Go Back to Previous Tag", group = "Tags" }
    ),

    -- DIRECT TAG ACCESS (Number Row 1-9) --
    -- Mod4 + Number (1-9): View tag N exclusively
    -- This has been refactored from `viewtoggle` to `view_only` for exclusive viewing
    awful.key({
        modifiers = { modkey },
        keygroup = "numrow", -- Maps to number keys 1-9
        description = "View Tag",
        group = "Tags",
        on_press = function(index)
            local screen = awful.screen.focused() -- Get currently focused screen
            if screen and screen.tags and screen.tags[index] then
                local tag = screen.tags[index] -- Get the tag at the specified index
                tag:view_only() -- Switch to this tag exclusively (hide all others)
            end
        end,
    }),

    -- CLIENT MOVEMENT BETWEEN TAGS --
    -- Mod4 + Shift + Number (1-9): Move focused client to tag N
    awful.key({
        modifiers = { modkey, "Shift" },
        keygroup = "numrow", -- Maps to number keys 1-9
        description = "Move Focused Client to Tag",
        group = "Tags",
        on_press = function(index)
            if capi.client.focus then -- Check if there's a focused client
                local tag = capi.client.focus.screen.tags[index] -- Get target tag
                if tag then
                    capi.client.focus:move_to_tag(tag) -- Move client to the specified tag
                end
            end
        end,
    }),

    -- CLIENT TAG TOGGLING --
    -- Mod4 + Ctrl + Shift + Number (1-9): Toggle focused client on tag N
    -- Adds/removes the focused client from the specified tag's visible clients
    awful.key({
        modifiers = { modkey, "Control", "Shift" },
        keygroup = "numrow", -- Maps to number keys 1-9
        description = "Toggle Focused Client on Tag",
        group = "Tags",
        on_press = function(index)
            if capi.client.focus then -- Check if there's a focused client
                local tag = capi.client.focus.screen.tags[index] -- Get target tag
                if tag then
                    capi.client.focus:toggle_tag(tag) -- Add/remove client from tag
                end
            end
        end,
    }),
})
