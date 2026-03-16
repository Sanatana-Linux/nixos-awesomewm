-- ui/bar/init.lua
-- This module defines and assembles the main status bar (wibar) for AwesomeWM.
-- This version corrects the layout to remove the duplicated time widget.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local menu = require("ui.popups.menu").get_default()

-- Load wibar component modules
local launcher_button = require("ui.bar.modules.launcher_button")
local control_panel_button = require("ui.bar.modules.control_panel_button")
local time_widget = require("ui.bar.modules.time_widget")
local tray_widget = require("ui.bar.modules.tray_widget")
local layoutbox_widget = require("ui.bar.modules.layoutbox_widget")
local new_tags_widget = require("ui/bar/modules/taglist_and_tasklist_buttons")
local battery_widget = require("ui.bar.modules.battery")

local bar = {}

-- Define button configurations once to be reused
local taglist_buttons = awful.util.table.join(
    awful.button({}, 1, function(t)
        t:view_only()
    end),
    awful.button({ "Mod4" }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ "Mod4" }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end)
)

-- Define the correct behavior for tasklist (client icon) clicks
local tasklist_buttons = awful.util.table.join(
    awful.button({}, 1, function(c)
        awful.client.jumpto(c)
    end),
    awful.button({}, 3, function(c)
        menu:toggle_client_menu(c)
    end)
)

-- Creates the wibar for the primary screen.
function bar.create_primary(s)
    local wibar = awful.wibar({
        position = "bottom",
        type = "dock",
        screen = s,
        height = dpi(30),
        border_width = dpi(0),
        border_color = beautiful.bg .. "66",
        bg = beautiful.bg .. "99",
        margins = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0,
        },
        widget = {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                widget = wibox.container.margin,
                margins = {
                    top = dpi(2),
                    bottom = dpi(2),
                    left = dpi(7),
                    right = dpi(7),
                },
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(8),
                    launcher_button(),
                },
            },
            { -- Center widgets
                widget = wibox.container.margin,
                margins = {
                    top = dpi(2),
                    bottom = dpi(2),
                    left = dpi(7),
                    right = dpi(7),
                },
                new_tags_widget.new({
                    screen = s,
                    taglist_buttons = taglist_buttons,
                    tasklist_buttons = tasklist_buttons,
                }),
            },
            { -- Right widgets
                widget = wibox.container.margin,
                margins = {
                    top = dpi(2),
                    bottom = dpi(2),
                    left = 0,
                    right = dpi(7),
                },
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(8),
                    tray_widget(),
                    layoutbox_widget(s),
                    battery_widget(),
                    time_widget(), -- Correctly placed exactly once
                    control_panel_button(),
                },
            },
        },
    })
    return wibar
end

-- Wibar for secondary screens.
function bar.create_secondary(s)
    local tags_widget = new_tags_widget.new({
        screen = s,
        taglist_buttons = taglist_buttons,
        tasklist_buttons = tasklist_buttons,
    })

    local wibar = awful.wibar({
        position = "bottom",
        type = "dock",
        screen = s,
        height = dpi(40),
        border_width = 0,
        border_color = "#00000000",
        bg = beautiful.bg .. "99",
        margins = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0,
        },
        widget = {
            layout = wibox.layout.align.horizontal,
            nil,
            {
                widget = wibox.container.margin,
                margins = dpi(7),
                tags_widget,
            },
            nil,
        },
    })
    return wibar
end

return bar
