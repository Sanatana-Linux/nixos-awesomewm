---@diagnostic disable: undefined-global
local awful = require("awful")
local naughty = require("naughty")
local gtimer = require("gears.timer")
local beautiful = require("beautiful")
local has_common = require("lib").has_common
local capi = { screen = screen, client = client }

local wallpaper = require("ui.wallpaper")
local bar = require("ui/bar")
local menu = require("ui.menu").get_default()
local notification = require("ui.notification").get_default()
local launcher = require("ui.launcher").get_default()
local powermenu = require("ui.powermenu").get_default()
local control_panel = require("ui.control_panel").get_default()

-- Explicitly load the screenshot notification handler to ensure it's ready
require("ui.notification.screenshots")

local function set_wibar_hideaway(wibar, s)
    if not wibar or not s then
        return
    end

    local hide_timer
    wibar.visible = false

    -- Timer to check mouse position and show/hide the wibar
    gtimer.start_new(0.2, function()
        local coords = mouse.coords()
        if not coords then return true end -- Prevent crash if coords are nil

        local on_edge = coords.y >= s.geometry.y + s.geometry.height - 1
        local mouse_on_bar = coords.x >= wibar.x and coords.x < wibar.x + wibar.width and
                             coords.y >= wibar.y and coords.y < wibar.y + wibar.height

        if on_edge or mouse_on_bar then
            -- Show the bar if the mouse is at the bottom edge or on the bar itself
            wibar.visible = true
            if hide_timer then
                hide_timer:stop()
                hide_timer = nil
            end
        else
            -- If the mouse is not on the bar or the edge, start a timer to hide it
            if wibar.visible and not hide_timer then
                hide_timer = gtimer.start_new(0.5, function()
                    wibar.visible = false
                    hide_timer = nil
                    return false -- Run only once
                end)
            end
        end
        return true -- Keep the timer running
    end)

    -- Fullscreen handling
    local function on_client_fullscreen_change(c)
        local focused_screen = awful.screen.focused({ client = c })
        if wibar.screen == focused_screen and has_common(c:tags(), focused_screen.selected_tags) then
            if c.fullscreen then
                wibar.visible = false
            end
        end
    end

    capi.client.connect_signal("property::fullscreen", on_client_fullscreen_change)
end

capi.screen.connect_signal("request::desktop_decoration", function(s)
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

    set_wibar_hideaway(s.bar, s)
end)

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
    end
end)

launcher:connect_signal("property::shown", function(_, shown)
    if shown == true then
        powermenu:hide()
        menu:hide()
    end
end)

control_panel:connect_signal("property::shown", function(_, shown)
    if shown == true then
        powermenu:hide()
        menu:hide()
    end
end)

local function click_hideaway()
    menu:hide()
    launcher:hide()
    powermenu:hide()
    control_panel:hide()
end

awful.mouse.append_global_mousebinding(awful.button({}, 1, click_hideaway))

capi.client.connect_signal("request::manage", function(c)
    c:connect_signal("button::press", click_hideaway)
end)

require("ui.titlebar")
require("ui.tabbar")
require("ui.window_switcher")
