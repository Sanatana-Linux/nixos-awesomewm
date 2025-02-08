local awful = require("awful")
local dropdown = require("ui.dropdown")
local apps = require("main.apps")
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require("menubar")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

modkey = "Mod4"

awful.keyboard.append_global_keybindings({
    awful.key(
        { modkey },
        "F1",
        hotkeys_popup.show_help,
        { description = "show keybindings table", group = "awesome" }
    ),

    -- -------------------------------------------------------------------------- --

    awful.key(
        { modkey },
        "r",
        awesome.restart,
        { description = "reload awesome", group = "awesome" }
    ),


    awful.key(
        { modkey },
        "d",
        awesome.emit_signal("toggle::dash"),
        { description = "toggle dashboard", group = "awesome" }
    ),


    -- -------------------------------------------------------------------------- --

    awful.key(
        { modkey, "Shift" },
        "q",
        awesome.quit,
        { description = "quit awesome", group = "awesome" }
    ),

    -- -------------------------------------------------------------------------- --

    awful.key({ modkey }, "Return", function()
        dropdown.toggle(apps.terminal, "left", "top", 0.75, 0.75)
    end, { description = "open a terminal", group = "launcher" }),

    -- -------------------------------------------------------------------------- --

    awful.key({ modkey, "Control" }, "Return", function()
        awful.spawn(apps.terminal)
    end, { description = "open a dropdown terminal", group = "awesome" }),

    -- -------------------------------------------------------------------------- --

    awful.key({ modkey, "Shift" }, "Return", function()
        awesome.emit_signal("toggle::launcher")
    end, { description = "open application launch menu", group = "awesome" }),

    -- -------------------------------------------------------------------------- --

    awful.key({ modkey }, "p", function()
        menubar.show()
    end, { description = "show the menubar", group = "awesome" }),

    -- -------------------------------------------------------------------------- --
    -- Client Selection Menu
    awful.key({ modkey }, "Tab", function()
        awful.menu.menu_keys.down = { "Down", "Alt_L" }
        awful.menu.menu_keys.up = { "Up", "Alt_R" }
        awful.menu.clients({
            theme = {
                width = dpi(450),
                bg = beautiful.bg_gradient,
                border_color = beautiful.fg3 .. "99",
                border_width = dpi(1),
            },
        }, { keygrabber = true })
    end, { description = "Client Selection Menu", group = "awesome" }),
    -- -------------------------------------------------------------------------- --
    -- Tab Between Applications
    awful.keygrabber({
        keybindings = {
            awful.key({
                modifiers = { "Mod1" },
                key = "Tab",
                on_press = function()
                    awesome.emit_signal("window_switcher::next")
                end,
            }),
        },
        root_keybindings = {
            awful.key({
                modifiers = { "Mod1" },
                key = "Tab",
                on_press = function() end,
            }),
        },
        stop_key = "Mod1",
        stop_event = "release",
        start_callback = function()
            awesome.emit_signal("window_switcher::toggle")
        end,
        stop_callback = function()
            awesome.emit_signal("window_switcher::raise")
            awesome.emit_signal("window_switcher::toggle")
        end,
        export_keybindings = true,
    }),
})
