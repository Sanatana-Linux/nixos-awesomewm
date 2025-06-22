---@diagnostic disable: undefined-global
local capi = {client = client} -- Shorthand for client object
local awful = require("awful") -- AwesomeWM utility library
local snap_edge = require("modules.snap_edge") -- Window snapping helper
local numpad_map = { 87, 88, 89, 83, 84, 85, 79, 80, 81 } -- Keycodes for numpad keys

local menu = require("ui.menu").get_default() -- Client menu module
local modkey = "Mod4" -- Set modkey (usually the Super/Windows key)

-- Connect to the signal to set up default client keybindings
capi.client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({

        -- Toggle client menu for the focused window
        awful.key({ modkey }, "f", function(c)
            menu:toggle_client_menu(c)
        end, { description = "toggle client menu", group = "Client" }),

        -- Close the focused window
        awful.key({ modkey }, "w", function(c)
            c:kill()
        end, { description = "close focused window", group = "Client" }),

        -- Toggle floating mode for the focused window
        awful.key(
            { modkey, "Control" },
            "z",
            awful.client.floating.toggle,
            { description = "toggle floating window", group = "Client" }
        ),

        -- Swap the focused window with the master window
        awful.key({ modkey }, "\\", function(c)
            c:swap(awful.client.getmaster())
        end, { description = "move to master", group = "Client" }),

        -- Move the focused window to another screen
        awful.key({ modkey }, "o", function(c)
            c:move_to_screen()
        end, { description = "move to screen", group = "Client" }),

        -- Toggle "always on top" for the focused window
        awful.key({ modkey }, "t", function(c)
            c.ontop = not c.ontop
        end, { description = "toggle keep window on top", group = "Client" }),

        -- Minimize the focused window
        awful.key({ modkey }, "n", function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end, { description = "minimize", group = "Client" }),

        -- Toggle maximized state for the focused window
        awful.key({ modkey }, "m", function(c)
            c.maximized = not c.maximized
            c:raise()
        end, { description = "(un)maximize", group = "Client" }),

        -- Toggle vertical maximization for the focused window
        awful.key({ modkey, "Control" }, "m", function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end, {
            description = "(un)maximize vertically",
            group = "Client",
        }),

        -- Toggle horizontal maximization for the focused window
        awful.key({ modkey, "Shift" }, "m", function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end, {
            description = "(un)maximize horizontally",
            group = "Client",
        }),

        -- -------------------------------------------------------------------------- --
        -- Resize floating windows with arrow keys

        -- Decrease floating client height
        awful.key({ modkey, "Control" }, "Down", function()
            awful.client.moveresize(0, 0, 0, -20)
        end, {
            description = "Decrease floating client height",
            group = "Client",
        }),
        -- Increase floating client height
        awful.key({ modkey, "Control" }, "Up", function()
            awful.client.moveresize(0, 0, 0, 20)
        end, {
            description = "Increase floating client height",
            group = "Client",
        }),
        -- Decrease floating client width
    	awful.key({ modkey, "Control" }, "Left", function()
            awful.client.moveresize(0, 0, -20, 0)
        end, {
            description = "Decrease floating client width",
            group = "Client",
        }),
        -- Increase floating client width
        awful.key({ modkey, "Control" }, "Right", function()
            awful.client.moveresize(0, 0, 20, 0)
        end, {
            description = "Increase floating client width",
            group = "Client",
        }),

        -- -------------------------------------------------------------------------- --
        -- Move floating windows with Shift + arrow keys

        -- Move window down
        awful.key({ modkey, "Shift" }, "Down", function()
            awful.client.moveresize(0, 20, 0, 0)
        end, {
            description = "Move window down",
            group = "Client",
        }),
        -- Move window up
        awful.key({ modkey, "Shift" }, "Up", function()
            awful.client.moveresize(0, -20, 0, 0)
        end, {
            description = "Move window up",
            group = "Client",
        }),
        -- Move window left
        awful.key({ modkey, "Shift" }, "Left", function()
            awful.client.moveresize(-20, 0, 0, 0)
        end, {
            description = "Move window left",
            group = "Client",
        }),
        -- Move window right
        awful.key({ modkey, "Shift" }, "Right", function()
            awful.client.moveresize(20, 0, 0, 0)
        end, {
            description = "Move window right",
            group = "Client",
        }),

        -- -------------------------------------------------------------------------- --
        -- Window Snapping (requires keypad)

        -- Snap to bottom left
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[1], function(c)
            snap_edge(c, "bottomleft")
        end, {
            description = "snap to bottom left",
            group = "Client",
        }),

        -- Snap to bottom
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[2], function(c)
            snap_edge(c, "bottom")
        end, {
            description = "snap to bottom",
            group = "Client",
        }),

        -- Snap to bottom right
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[3], function(c)
            snap_edge(c, "bottomright")
        end, {
            description = "snap to bottom right",
            group = "Client",
        }),

        -- Snap to left
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[4], function(c)
            snap_edge(c, "left")
        end, {
            description = "snap to left",
            group = "Client",
        }),

        -- Snap to center
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[5], function(c)
            snap_edge(c, "center")
        end),

        -- Snap to right
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[6], function(c)
            snap_edge(c, "right")
        end, {
            description = "snap to right",
            group = "Client"
        }),

        -- Snap to top left
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[7], function(c)
            snap_edge(c, "topleft")
        end, {
            description = "snap to top left",
            group = "Client"
        }),

        -- Snap to top
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[8], function(c)
            snap_edge(c, "top")
        end, {
            description = "snap to top",
            group = "Client"
        }),

        -- Snap to top right
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[9], function(c)
            snap_edge(c, "topright")
        end, {
            description = "snap to top right",
            group = "Client"
        }),
    })
end)
