---@diagnostic disable: undefined-global
local awful = require("awful")
local naughty = require("naughty")
local gtimer = require("gears.timer")
local beautiful = require("beautiful")
local has_common = require("lib").has_common
local capi = { screen = screen, client = client }

local wallpaper = require("ui.wallpaper")
local bar = require("ui/bar")
local menu = require("ui.popups.menu").get_default()
local notification = require("ui.notification").get_default()
local launcher = require("ui.popups.launcher").get_default()
local powermenu = require("ui.popups.powermenu").get_default()
local control_panel = require("ui.popups.control_panel").get_default()
local screenshot_popup = require("ui.popups.screenshot_popup").get_default()

-- Explicitly load the screenshot notification handler to ensure it's ready
require("ui.notification.screenshots")

-- Function to create bar for a given screen
local function setup_screen_bar(s)
    -- Debug: log that we're trying to create a bar
    io.stderr:write(
        string.format(
            "[BAR] Setting up bar for screen %d (primary: %s)\n",
            s.index,
            tostring(s == capi.screen.primary)
        )
    )

    -- Skip if bar already exists
    if s.bar then
        io.stderr:write(
            string.format("[BAR] Screen %d already has a bar, skipping\n", s.index)
        )
        return
    end

    local success, err = pcall(function()
        if s == capi.screen.primary then
            s.bar = bar.create_primary(s)
            s.bar:connect_signal("property::visible", function()
                if control_panel.visible == true then
                    gtimer.delayed_call(function()
                        awful.placement.bottom_right(control_panel, {
                            honor_workarea = true,
                            margins = beautiful.useless_gap,
                        })
                    end)
                end

                if launcher.visible == true then
                    gtimer.delayed_call(function()
                        awful.placement.bottom_left(launcher, {
                            honor_workarea = true,
                            margins = beautiful.useless_gap,
                        })
                    end)
                end
            end)
        else
            s.bar = bar.create_secondary(s)
        end

        s.bar.visible = true
        awful.placement.bottom(s.bar, {
            honor_workarea = false,
            margins = { bottom = 0 },
        })
    end)

    if not success then
        naughty.notification({
            urgency = "critical",
            title = "Bar Creation Error",
            message = string.format(
                "Failed to create bar for screen %d: %s",
                s.index,
                tostring(err)
            ),
        })
    end
end

-- Setup bars for all existing screens
awful.screen.connect_for_each_screen(setup_screen_bar)

-- Also handle screens added later (hot-plug)
screen.connect_signal("added", setup_screen_bar)

capi.screen.connect_signal("request::wallpaper", function(s)
    s.wallpaper = wallpaper(s)

    s.wallpaper:set_image(beautiful.wallpaper)
end)

naughty.connect_signal("request::display", function(n)
    notification.display(n)
end)

powermenu:connect_signal("property::shown", function(_, shown)
    if shown == true then
        launcher:hide()
        control_panel:hide()
        menu:hide()
        screenshot_popup:hide()
    end
end)

launcher:connect_signal("property::shown", function(_, shown)
    if shown == true then
        powermenu:hide()
        menu:hide()
        screenshot_popup:hide()
    end
end)

control_panel:connect_signal("property::shown", function(_, shown)
    if shown == true then
        powermenu:hide()
        menu:hide()
        screenshot_popup:hide()
    end
end)

screenshot_popup:connect_signal("property::shown", function(_, shown)
    if shown == true then
        powermenu:hide()
        menu:hide()
        launcher:hide()
        control_panel:hide()
    end
end)

local function click_hideaway()
    menu:hide()
    launcher:hide()
    powermenu:hide()
    control_panel:hide()
    screenshot_popup:hide()
end

awful.mouse.append_global_mousebinding(awful.button({}, 1, click_hideaway))

capi.client.connect_signal("request::manage", function(c)
    c:connect_signal("button::press", click_hideaway)
end)

require("ui.titlebar")
require("ui.tabbar")
require("ui.popups.window_switcher")
