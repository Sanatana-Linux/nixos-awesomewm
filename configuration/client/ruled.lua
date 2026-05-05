local awful = require("awful")
local rclient = require("ruled.client")
local rnotification = require("ruled.notification")
local signals = require("configuration.client.signals")

rclient.connect_signal("request::rules", function()
    rclient.append_rule({
        id = "global",
        rule = {},
        properties = {
            titlebars_enabled = true,
            screen = awful.screen.preferred,
            focus = awful.client.focus.filter,
            raise = true,
            size_hints_honor = false,
            placement = signals.center_and_keep_on_screen,
        },
    })

    rclient.append_rule({
        id = "titlebars",
        rule_any = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = true },
    })

    rclient.append_rule({
        rule_any = { class = { "mpv" } },
        properties = { width = 1280, height = 720 },
    })

    rclient.append_rule({
        id = "xephyr_fixed_size",
        rule_any = { class = { "xephyr_1", "Xephyr" } },
        properties = {
            min_width = 1200,
            max_width = 1200,
            min_height = 800,
            max_height = 800,
            size_hints_honor = true,
            titlebars_enabled = false,
            special = true,
            floating = true,
            raise = true,
            centered = true,
            screen = awful.screen.preferred,
            placement = signals.center_and_keep_on_screen,
            ontop = false,
        },
    })

    rclient.append_rule({
        id = "floating",
        rule_any = {
            instance = { "copyq", "pinentry" },
            class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "Sxiv",
                "Tor Browser",
                "Vlc",
                "xtightvncviewer",
                "nvidia-settings",
                "ark",
                "org.gnome.FileRoller",
            },
            name = { "Event Tester" },
            role = { "AlarmWindow", "ConfigManager", "pop-up" },
        },
        properties = {
            titlebars_enabled = true,
            floating = true,
            raise = true,
            size_hints_honor = true,
            centered = true,
            screen = awful.screen.preferred,
            placement = signals.center_and_keep_on_screen,
        },
    })

    rclient.append_rule({
        rule_any = {
            type = { "utility" },
            class = {
                "vlc",
                "firefox",
                "firefoxdeveloperedition",
                "firefox-nightly",
            },
        },
        properties = {
            disallow_autocenter = true,
        },
    })
end)

rnotification.connect_signal("request::rules", function()
    rnotification.append_rule({
        id = "global",
        rule = {},
        properties = {
            timeout = 5,
        },
    })

    rnotification.append_rule({
        id = "screenshot_rule",
        rule = {
            app_name = "Screenshot",
        },
        properties = {
            timeout = 0,
        },
    })
end)
