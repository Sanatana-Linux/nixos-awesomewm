--  ______ __ __               __
-- |      |  |__|.-----.-----.|  |_
-- |   ---|  |  ||  -__|     ||   _|
-- |______|__|__||_____|__|__||____|
-- -------------------------------------------------------------------------- --
local numpad_map = { 87, 88, 89, 83, 84, 85, 79, 80, 81 }
-- -------------------------------------------------------------------------- --
client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Control" }, "f", function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end, { description = "toggle fullscreen", group = "Client" }),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey }, "w", function(c)
            c:kill()
        end, { description = "close", group = "Client" }),
        -- -------------------------------------------------------------------------- --
        --
        awful.key(
            { modkey },
            "f",
            awful.client.floating.toggle,
            { description = "toggle floating", group = "Client" }
        ),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey }, "g", function(c)
            c:swap(awful.client.getmaster())
        end, { description = "move to master", group = "Client" }),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey }, "o", function(c)
            c:move_to_screen()
        end, { description = "move to screen", group = "Client" }),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey }, "t", function(c)
            c.ontop = not c.ontop
        end, { description = "toggle keep on top", group = "Client" }),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey }, "n", function(c)
            c.minimized = true
        end, { description = "minimize", group = "Client" }),

        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey }, "m", function(c)
            c.maximized = not c.maximized
            c:raise()
        end, { description = "(un)maximize", group = "Client" }),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Control" }, "m", function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end, {
            description = "(un)maximize vertically",
            group = "Client",
        }),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Shift" }, "m", function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end, {
            description = "(un)maximize horizontally",
            group = "Client",
        }),

        -- -------------------------------------------------------------------------- --
        --                               Window Snapping                              --
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[1], function(c)
            modules.snap_edge(c, "bottomleft")
        end),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[2], function(c)
            modules.snap_edge(c, "bottom")
        end),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[3], function(c)
            modules.snap_edge(c, "bottomright")
        end),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[4], function(c)
            modules.snap_edge(c, "left")
        end),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[5], function(c)
            modules.snap_edge(c, "center")
        end),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[6], function(c)
            modules.snap_edge(c, "right")
        end),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[7], function(c)
            modules.snap_edge(c, "topleft")
        end),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[8], function(c)
            modules.snap_edge(c, "top")
        end),
        -- -------------------------------------------------------------------------- --
        --
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[9], function(c)
            modules.snap_edge(c, "topright")
        end),
    })
end)
