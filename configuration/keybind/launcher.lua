---@diagnostic disable: undefined-global
local awful = require("awful")
local dropdown = require("modules.dropdown")
local launcher = require("ui.popups.launcher").get_default()
local menubar = require("menubar")
local modkey = "Mod4"

awful.keyboard.append_global_keybindings({

    -- -------------------------------------------------------------------------- --
    -- Terminal
    awful.key({ modkey }, "Return", function()
        dropdown.toggle("kitty", "left", "top", 0.75, 0.75)
    end, { description = "open a dropdown terminal", group = "Launcher" }),

    awful.key({ modkey, "Control" }, "Return", function()
        awful.spawn("kitty")
    end, { description = "open a terminal window", group = "Launcher" }),

    -- -------------------------------------------------------------------------- --
    -- App Launcher
    awful.key({ modkey, "Shift" }, "Return", function()
        launcher:show()
    end, { description = "open application launch menu", group = "Launcher" }),

    awful.key({ modkey }, "p", function()
        menubar.show()
    end, { description = "show the menubar", group = "Launcher" }),
})
