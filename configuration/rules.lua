--  ______         __
-- |   __ \.--.--.|  |.-----.-----.
-- |      <|  |  ||  ||  -__|__ --|
-- |___|__||_____||__||_____|_____|
-- ----------------------------------------------------------- --

local awful = require("awful")
local beautiful = require("beautiful")
local ruled = require("ruled")
local gears = require("gears")

ruled.client.connect_signal("request::rules", function()
    -- Global
    ruled.client.append_rule({
        id = "global",
        rule = {},
        properties = {
            focus = awful.client.focus.filter,
            raise = true,
            above = false,
            below = false,
            size_hints_honor = true,
            ontop = false,
            honor_padding = true,
            honor_workarea = true,
            sticky = false,
            screen = awful.screen.preferred,
            placement = awful.placement.under_mouse
                -- + awful.placement.no_overlap
                + awful.placement.no_offscreen,
        },
    })

    -- tasklist order
    ruled.client.append_rule({
        id = "tasklist_order",
        rule = {},
        properties = {},
        callback = awful.client.setslave,
    })

    -- Floating
    ruled.client.append_rule({
        id = "floating",
        rule_any = {
            class = {
                "Arandr",
                "Blueman-manager",
                ".shutter-unwrapped",

                "Sxiv",
                "feh",
                "imv",
                "imv-dir",
                "fzfmenu",
                "Gpick",
                "Kruler",
                "MessageWin", -- kalarm.
                "Sxiv",
                "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                "Wpa_gui",
                "veromix",
                "xtightvncviewer",
            },
            role = {
                "AlarmWindow", -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
            },
            name = { "Friends List", "Steam - News" },
            instance = { "spad", "discord", "music" },
        },
        properties = { floating = true, placement = awful.placement.centered },
    })

    -- Center Placement
    ruled.client.append_rule({
        id = "center_placement",
        rule_any = {
            type = { "dialog" },
            class = { "Steam", "discord", "markdown_input", "scratchpad" },
            instance = { "markdown_input", "scratchpad" },
            role = { "GtkFileChooserDialog", "conversation" },
        },
        properties = {
            placement = awful.placement.center + awful.placement.no_offscreen,
        },
    })

    -- Titlebar rules
    ruled.client.append_rule({
        id = "titlebars",
        rule_any = {
            type = { "normal", "dialog" },
            class = { "kitty" },
            instance = { "markdown_input", "scratchpad" },
        },
        except_any = {
            class = {
                "Steam",
                "zoom",
                "jetbrains-studio",
                "Lutris",
                "net-technicpack-launcher-LauncherMain",
            },
            type = { "splash" },
            instance = { "onboard" },
            name = { "^discord.com is sharing your screen.$" },
        },
        properties = {
            titlebars_enabled = true,
            hide_titlebars = false,
            size_hints_honor = true,
            honor_padding = true,
            honor_workarea = true,
            round_corners = true,
        },
    })
end)
