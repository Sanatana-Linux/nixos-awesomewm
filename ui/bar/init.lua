-- ui/bar/init.lua
-- Hover-reveal status bar (wibar) for AwesomeWM.
-- Slides in from the bottom on mouse hover.
-- @module ui.bar

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local dpi = beautiful.xresources.apply_dpi
local menu = require("ui.popups.menu").get_default()
local hover_bar = require("ui.bar.hover_bar")

-- Load wibar component modules
local launcher_button = require("ui.bar.modules.launcher_button")
local control_panel_button = require("ui.bar.modules.control_panel_button")
local time_widget = require("ui.bar.modules.time_widget")
local tray_widget = require("ui.bar.modules.tray_widget")
local layoutbox_widget = require("ui.bar.modules.layoutbox_widget")
local new_tags_widget = require("ui.bar.modules.taglist_and_tasklist_buttons")
local battery_widget = require("ui.bar.modules.battery")

local bar = {}

--- Taglist and tasklist mouse-button bindings shared by both
-- primary and secondary bars.
-- Taglist: left-click views, Mod4+left moves client, right-click
-- toggles view, Mod4+right toggles client tag.
-- Tasklist: left-click jumps to, right-click opens client menu.
-- @treturn table A joined set of awful.button bindings
local taglist_buttons = gtable.join(
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

--- Tasklist button bindings.
-- Left-click: jump to client. Right-click: open client menu.
-- @treturn table A joined set of awful.button bindings
local tasklist_buttons = gtable.join(
    awful.button({}, 1, function(c)
        awful.client.jumpto(c)
    end),
    awful.button({}, 3, function(c)
        menu:toggle_client_menu(c)
    end)
)

--- Build the primary (main) screen wibar.
-- Primary bar is 30dp tall, with launcher button (left),
-- taglist + tasklist (center), and tray/layoutbox/battery/
-- time/control_panel buttons (right).
-- @tparam screen s The screen to attach the bar to
-- @treturn table The hover_bar instance
function bar.create_primary(s)
    local bar_widget = {
        layout = wibox.layout.align.horizontal,
        {
            -- Left widgets
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
        {
            -- Center widgets
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
        {
            -- Right widgets
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
                time_widget(),
                control_panel_button(),
            },
        },
    }

    local hb = hover_bar.create({
        screen = s,
        height = dpi(30),
        widget = bar_widget,
        is_primary = true,
    })
    return hb
end

--- Build the secondary-screen wibar.
-- Secondary bar is 40dp tall, showing only the taglist +
-- tasklist widget centered. Intended for external monitors.
-- @tparam screen s The screen to attach the bar to
-- @treturn table The hover_bar instance
function bar.create_secondary(s)
    local tags_widget = new_tags_widget.new({
        screen = s,
        taglist_buttons = taglist_buttons,
        tasklist_buttons = tasklist_buttons,
    })

    local bar_widget = {
        layout = wibox.layout.align.horizontal,
        nil,
        {
            widget = wibox.container.margin,
            margins = dpi(7),
            tags_widget,
        },
        nil,
    }

    local hb = hover_bar.create({
        screen = s,
        height = dpi(40),
        widget = bar_widget,
        is_primary = false,
    })
    return hb
end

return bar
