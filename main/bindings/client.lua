local client = client
local awful = require("awful")
local snap_edge = require("mods.snap_edge")
local numpad_map = { 87, 88, 89, 83, 84, 85, 79, 80, 81 }

client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({

        awful.key({ modkey }, "f", function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end, { description = "toggle fullscreen", group = "client" }),

        -- -------------------------------------------------------------------------- --

        awful.key({ modkey }, "w", function(c)
            c:kill()
        end, { description = "close", group = "client" }),

        -- -------------------------------------------------------------------------- --

        awful.key(
            { modkey, "Control" },
            "space",
            awful.client.floating.toggle,
            { description = "toggle floating", group = "client" }
        ),

        -- -------------------------------------------------------------------------- --

        awful.key({ modkey }, "\\", function(c)
            c:swap(awful.client.getmaster())
        end, { description = "move to master", group = "client" }),

        -- -------------------------------------------------------------------------- --

        awful.key({ modkey }, "o", function(c)
            c:move_to_screen()
        end, { description = "move to screen", group = "client" }),

        -- -------------------------------------------------------------------------- --

        awful.key({ modkey }, "t", function(c)
            c.ontop = not c.ontop
        end, { description = "toggle keep on top", group = "client" }),

        -- -------------------------------------------------------------------------- --

        awful.key({ modkey }, "n", function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end, { description = "minimize", group = "client" }),

        -- -------------------------------------------------------------------------- --

        awful.key({ modkey }, "m", function(c)
            c.maximized = not c.maximized
            c:raise()
        end, { description = "(un)maximize", group = "client" }),

        -- -------------------------------------------------------------------------- --

        awful.key({ modkey, "Control" }, "m", function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end, {
            description = "(un)maximize vertically",
            group = "client",
        }),

        -- -------------------------------------------------------------------------- --

        awful.key({ modkey, "Shift" }, "m", function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end, {
            description = "(un)maximize horizontally",
            group = "client",
        }),

        -- -------------------------------------------------------------------------- --
        -- Resize
        awful.key({ modkey, "Control" }, "Down", function()
            awful.client.moveresize(0, 0, 0, -20)
        end),
        awful.key({ modkey, "Control" }, "Up", function()
            awful.client.moveresize(0, 0, 0, 20)
        end),
        awful.key({ modkey, "Control" }, "Left", function()
            awful.client.moveresize(0, 0, -20, 0)
        end),
        awful.key({ modkey, "Control" }, "Right", function()
            awful.client.moveresize(0, 0, 20, 0)
        end),

        -- -------------------------------------------------------------------------- --
        -- Move
        awful.key({ modkey, "Shift" }, "Down", function()
            awful.client.moveresize(0, 20, 0, 0)
        end),
        awful.key({ modkey, "Shift" }, "Up", function()
            awful.client.moveresize(0, -20, 0, 0)
        end),
        awful.key({ modkey, "Shift" }, "Left", function()
            awful.client.moveresize(-20, 0, 0, 0)
        end),
        awful.key({ modkey, "Shift" }, "Right", function()
            awful.client.moveresize(20, 0, 0, 0)
        end),
        -- -------------------------------------------------------------------------- --
        -- Window Snapping (requires keypad)
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[1], function(c)
            snap_edge(c, "bottomleft")
        end),

        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[2], function(c)
            snap_edge(c, "bottom")
        end),

        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[3], function(c)
            snap_edge(c, "bottomright")
        end),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[4], function(c)
            snap_edge(c, "left")
        end),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[5], function(c)
            snap_edge(c, "center")
        end),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[6], function(c)
            snap_edge(c, "right")
        end),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[7], function(c)
            snap_edge(c, "topleft")
        end),
        -- -------------------------------------------------------------------------- --
        --6
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[8], function(c)
            snap_edge(c, "top")
        end),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[9], function(c)
            snap_edge(c, "topright")
        end),
    })
end)
