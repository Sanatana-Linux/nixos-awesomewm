---@diagnostic disable: undefined-global
--- UI orchestrator — loaded once at startup by `configuration/init.lua`.
-- Creates per-screen bars via `awful.screen.connect_for_each_screen`,
-- instantiates all popup singletons, wires mutual-exclusion signals
-- (only one popup visible at a time), and registers the root-click
-- hideaway binding.
-- @module ui
local awful = require("awful")
local naughty = require("naughty")
local gtimer = require("gears.timer")
local beautiful = require("beautiful")
local has_common = require("lib.util").has_common
local capi = { screen = screen, client = client }

local wallpaper = require("ui.wallpaper")
local bar = require("ui/bar")
local menu = require("ui.popups.menu").get_default()
local notification = require("ui.notification").get_default()
local launcher = require("ui.popups.launcher").get_default()
-- Wire the launcher's power button to the powermenu via a decoupled signal
launcher:connect_signal("launcher::power-clicked", function()
    powermenu:show()
end)
local powermenu = require("ui.popups.powermenu").get_default()
local control_panel = require("ui.popups.control_panel").get_default()
local screenshot_popup = require("ui.popups.screenshot_popup").get_default()
local day_info_panel = require("ui.popups.day_info_panel").get_default()
local battery = require("ui.popups.battery").get_default()

-- Load lockscreen
require("ui.lockscreen")

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
            string.format(
                "[BAR] Screen %d already has a bar, skipping\n",
                s.index
            )
        )
        return
    end

    local success, err = pcall(function()
        if s == capi.screen.primary then
            s.bar = bar.create_primary(s)
            s.bar.bar:connect_signal("property::visible", function()
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
        -- Hover bar manages its own visibility and positioning
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

--- Hide all popups on root-click.
-- Called on mouse button 1 on the desktop or on client press.
local function click_hideaway()
    menu:hide()
    launcher:hide()
    powermenu:hide()
    control_panel:hide()
    screenshot_popup:hide()
    day_info_panel:hide()
    battery:hide()
    -- Hide lockscreen if visible
    awesome.emit_signal("lockscreen::visible", false)
end

awful.mouse.append_global_mousebinding(awful.button({}, 1, click_hideaway))

capi.client.connect_signal("request::manage", function(c)
    c:connect_signal("button::press", click_hideaway)
end)

require("ui.titlebar")
require("ui.tabbar")
