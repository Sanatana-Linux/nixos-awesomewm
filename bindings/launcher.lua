---@diagnostic disable: undefined-global
--- Launcher keybindings.
-- Group: "Launcher".
--
-- Mod4+Return                   open a kitty dropdown terminal (75% width / height)
-- Mod4+Ctrl+Return              open a standalone kitty terminal
-- Mod4+Shift+Return             open the application launcher
-- Mod4+p                        toggle the control panel
-- Mod4+Shift+p                  show the menubar

local awful = require("awful")
local dropdown = require("modules.widgets.dropdown")
local launcher = require("ui.popups.launcher").get_default()
local control_panel = require("ui.popups.control_panel").get_default()
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
        control_panel:toggle()
    end, { description = "toggle control panel", group = "Launcher" }),

    awful.key({ modkey, "Shift" }, "p", function()
        menubar.show()
    end, { description = "show the menubar", group = "Launcher" }),
})
