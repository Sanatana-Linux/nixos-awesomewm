---@diagnostic disable: undefined-global
local capi = { client = client }
local awful = require("awful")
local snap_edge = require("modules.snap_edge")
local numpad_map = { 87, 88, 89, 83, 84, 85, 79, 80, 81 }

local menu = require("ui.popups.menu").get_default()
local modkey = "Mod4"

capi.client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({

        -- Toggle client menu for the focused window
        awful.key({ modkey }, "f", function(c)
            menu:toggle_client_menu(c)
        end, { description = "toggle client menu", group = "Window" }),

        -- Close the focused window
        awful.key({ modkey }, "w", function(c)
            c:kill()
        end, { description = "close focused window", group = "Window" }),

        -- Toggle floating mode for the focused window
        awful.key(
            { modkey },
            "z",
            awful.client.floating.toggle,
            { description = "toggle floating window", group = "Window" }
        ),

        -- Swap the focused window with the master window
        awful.key({ modkey }, "\\", function(c)
            c:swap(awful.client.getmaster())
        end, { description = "move to master", group = "Window" }),

        -- Move the focused window to another screen
        awful.key({ modkey }, "o", function(c)
            c:move_to_screen()
        end, { description = "move to screen", group = "Window" }),

        -- Toggle "always on top" for the focused window
        awful.key({ modkey }, "t", function(c)
            c.ontop = not c.ontop
        end, {
            description = "toggle keep window on top",
            group = "Window",
        }),

        -- Minimize the focused window
        awful.key({ modkey }, "n", function(c)
            c.minimized = true
        end, { description = "minimize", group = "Window" }),

        -- Toggle maximized state
        awful.key({ modkey }, "m", function(c)
            c.maximized = not c.maximized
            c:raise()
        end, { description = "(un)maximize", group = "Window" }),

        -- Toggle vertical maximization
        awful.key({ modkey, "Control" }, "m", function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end, {
            description = "(un)maximize vertically",
            group = "Window",
        }),

        -- Toggle horizontal maximization
        awful.key({ modkey, "Shift" }, "m", function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end, {
            description = "(un)maximize horizontally",
            group = "Window",
        }),

        -- -------------------------------------------------------------------------- --
        -- Resize floating windows with Ctrl + arrow keys

        awful.key({ modkey, "Control" }, "Down", function()
            awful.client.moveresize(0, 0, 0, -20)
        end, {
            description = "Decrease floating client height",
            group = "Window",
        }),
        awful.key({ modkey, "Control" }, "Up", function()
            awful.client.moveresize(0, 0, 0, 20)
        end, {
            description = "Increase floating client height",
            group = "Window",
        }),
        awful.key({ modkey, "Control" }, "Left", function()
            awful.client.moveresize(0, 0, -20, 0)
        end, {
            description = "Decrease floating client width",
            group = "Window",
        }),
        awful.key({ modkey, "Control" }, "Right", function()
            awful.client.moveresize(0, 0, 20, 0)
        end, {
            description = "Increase floating client width",
            group = "Window",
        }),

        -- -------------------------------------------------------------------------- --
        -- Move floating windows with Shift + arrow keys

        awful.key({ modkey, "Shift" }, "Down", function()
            awful.client.moveresize(0, 20, 0, 0)
        end, {
            description = "Move window down",
            group = "Window",
        }),
        awful.key({ modkey, "Shift" }, "Up", function()
            awful.client.moveresize(0, -20, 0, 0)
        end, {
            description = "Move window up",
            group = "Window",
        }),
        awful.key({ modkey, "Shift" }, "Left", function()
            awful.client.moveresize(-20, 0, 0, 0)
        end, {
            description = "Move window left",
            group = "Window",
        }),
        awful.key({ modkey, "Shift" }, "Right", function()
            awful.client.moveresize(20, 0, 0, 0)
        end, {
            description = "Move window right",
            group = "Window",
        }),

        -- -------------------------------------------------------------------------- --
        -- Window Snapping (numpad)

        awful.key({ modkey, "Shift" }, "#" .. numpad_map[1], function(c)
            snap_edge(c, "bottomleft")
        end, {
            description = "snap to bottom left",
            group = "Window",
        }),
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[2], function(c)
            snap_edge(c, "bottom")
        end, {
            description = "snap to bottom",
            group = "Window",
        }),
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[3], function(c)
            snap_edge(c, "bottomright")
        end, {
            description = "snap to bottom right",
            group = "Window",
        }),
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[4], function(c)
            snap_edge(c, "left")
        end, {
            description = "snap to left",
            group = "Window",
        }),
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[5], function(c)
            snap_edge(c, "center")
        end),
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[6], function(c)
            snap_edge(c, "right")
        end, {
            description = "snap to right",
            group = "Window",
        }),
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[7], function(c)
            snap_edge(c, "topleft")
        end, {
            description = "snap to top left",
            group = "Window",
        }),
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[8], function(c)
            snap_edge(c, "top")
        end, {
            description = "snap to top",
            group = "Window",
        }),
        awful.key({ modkey, "Shift" }, "#" .. numpad_map[9], function(c)
            snap_edge(c, "topright")
        end, {
            description = "snap to top right",
            group = "Window",
        }),
    })
end)
