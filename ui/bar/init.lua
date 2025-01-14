local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful").xresources.apply_dpi
local helpers = require("helpers")
local tasklist = require("ui.bar.mods.task")
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
    local wibar = awful.wibar({
        position = "bottom",
        height = dpi(48),
        ontop = true,
        screen = s or awful.screen.focused(),
        width = (s or awful.screen.focused()).geometry.width,
        bg = beautiful.bg .. '99',
        fg = beautiful.fg,

        widget = {
            {
                {
                    profile,
                    widget = wibox.container.margin,
                    left = dpi(5),
                    top = dpi(7),
                    bottom = dpi(7),
                    right = dpi(15),
                },
                {
                    require("ui.bar.mods.tags")(s),
                    widget = wibox.container.margin,
                    left = dpi(5),
                    top = dpi(7),
                    bottom = dpi(7),
                    right = dpi(5),
                },
                layout = wibox.layout.fixed.horizontal,

            },


            {

                tasklist,
                widget = wibox.container.margin,
                left = dpi(5),
                right = dpi(5),
                top = dpi(5),
                bottom = dpi(5),
            },
            {
                {
                    {
                        systray,

                        {
                            layout = wibox.layout.fixed.horizontal,
                            wifi,
                            bluetooth,
                            spacing = dpi(10),
                            widget = wibox.container.background,
                            buttons = {
                                awful.button({}, 1, function()
                                    awesome.emit_signal("toggle::control")
                                end),
                            },
                        },


                        layout,
                        notifications_button,
                        battery,
                        hourminutes,
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
