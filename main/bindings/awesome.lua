local awful = require("awful")
local dropdown = require("ui.dropdown")
local apps = require("main.apps")
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require("menubar")

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
})
