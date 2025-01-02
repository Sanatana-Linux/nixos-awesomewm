local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful").xresources.apply_dpi
local helpers = require("helpers")

local profile = require("ui.bar.mods.profile")
local battery = require("ui.bar.mods.battery")
local wifi = require("ui.bar.mods.wifi")
local bluetooth = require("ui.bar.mods.bluetooth")
local hourminutes = require("ui.bar.mods.time")
local layout = require("ui.bar.mods.layout")
local systray = require("ui.bar.mods.systray")
local notifications_button = require("ui.bar.mods.notifications_button")
local exit_button = require("ui.bar.mods.exit_button")

local function init(s)
    local get_tags = require("ui.bar.mods.tags")
    local taglist = get_tags.new({
        screen = s,
        taglist = {
            buttons = {
                awful.button({}, 1, function(t)
                    t:view_only()
                end),
                awful.button({ modkey }, 1, function(t)
                    if client.focus then
                        client.focus:move_to_tag(t)
                    end
                end),
                awful.button({}, 3, awful.tag.viewtoggle),
            },
        },
        tasklist = {
            buttons = {

                awful.button({}, 1, function(c)
                    if c ~= nil then
                        if not c:isvisible() and c.first_tag then
                            c.first_tag:view_only()
                        end
                        c:emit_signal("request::activate")
                        c:raise()
                        c.minimized = false
                    end
                end),
                awful.button({}, 3, function(c)
                    c:activate({ context = "titlebar", action = "mouse_resize" })
                end),
            },
        },
    })

    local wibar = awful.wibar({
        position = "bottom",
        height = dpi(36),
        ontop = true,
        screen = s,
        width = s.geometry.width,
        bg = beautiful.bg_gradient,
        fg = beautiful.fg1,

        widget = {

            {
                profile,
                widget = wibox.container.margin,
                left = dpi(5),
                top = dpi(3),
                bottom = dpi(3),
                right = dpi(10),
            },
            {
                taglist,
                widget = wibox.container.margin,
                left = dpi(10),
                top = dpi(3),
                bottom = dpi(3),
                right = dpi(10),
            },

            {
                {
                    {
                        systray,
                        battery,
                        {
                            layout = wibox.layout.fixed.horizontal,
                            wifi,
                            bluetooth,
                            widget = wibox.container.background,
                            buttons = {
                                awful.button({}, 1, function()
                                    awesome.emit_signal("toggle::control")
                                end),
                            },
                        },
                        hourminutes,
                        layout,
                        notifications_button,
                        exit_button,
                        widget = wibox.container.margin,
                        top = dpi(10),
                        bottom = dpi(10),
                        left = dpi(10),
                        right = dpi(10),
                        layout = wibox.layout.fixed.horizontal,
                        spacing = dpi(10),
                    },
                    widget = wibox.container.place,
                    valign = "center",
                },
                widget = wibox.container.margin,
                right = 5,
            },
            layout = wibox.layout.align.horizontal,
        },
    })
    return wibar
end

screen.connect_signal("request::desktop_decoration", function(s)
    s.wibox = init(s)
end)
