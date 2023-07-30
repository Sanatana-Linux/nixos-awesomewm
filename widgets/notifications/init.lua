local naughty = require("naughty")

local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local dpi = beautiful.xresources.apply_dpi
local ruled = require("ruled")

local menubar = require("menubar")

naughty.connect_signal("request::icon", function(n, context, hints)
    if context ~= "app_icon" then
        return
    end

    local path = menubar.utils.lookup_icon(hints.app_icon)
        or menubar.utils.lookup_icon(hints.app_icon:lower())

    if path then
        n.icon = path
    end
end)

require("widgets.notifications.brightness")
require("widgets.notifications.playerctl")
require("widgets.notifications.volume")
require("widgets.notifications.battery")

naughty.config.defaults.ontop = true
naughty.config.defaults.screen = awful.screen.focused()
naughty.config.defaults.timeout = 6
naughty.config.defaults.title = "System Notification"
--naughty.config.defaults.position = "top_right"

-- Timeouts
naughty.config.presets.low.timeout = 3
naughty.config.presets.critical.timeout = 0

naughty.config.presets.normal = {
    font = beautiful.font_name,
    fg = beautiful.fg_normal,
    bg = beautiful.bg_normal,
}

naughty.config.presets.low = {
    font = beautiful.font_name,
    fg = beautiful.fg_normal,
    bg = beautiful.bg_normal,
}

naughty.config.presets.critical = {
    font = beautiful.font,
    fg = beautiful.fg_focus,
    bg = beautiful.bg_normal,
    timeout = 0,
}

naughty.config.presets.ok = naughty.config.presets.normal
naughty.config.presets.info = naughty.config.presets.normal
naughty.config.presets.warn = naughty.config.presets.critical

ruled.notification.connect_signal("request::rules", function()
    -- All notifications will match this rule.
    ruled.notification.append_rule({
        rule = {},
        properties = { screen = awful.screen.focused(), implicit_timeout = 6 },
    })
end)

naughty.connect_signal("added", function()
    --    modules.sfx.play()
end)

naughty.connect_signal("request::display", function(n)
    local appicon = icons.message_square
    local time = os.date("%H:%M")

    local action_widget = {
        {
            {
                id = "text_role",
                align = "center",
                valign = "center",
                font = beautiful.title_font .. " 11",
                widget = wibox.widget.textbox,
            },
            left = dpi(6),
            top = dpi(6),
            bottom = dpi(6),
            right = dpi(6),
            widget = wibox.container.margin,
        },
        bg = beautiful.bg_contrast,
        border_width = dpi(0.5),
        border_color = beautiful.grey,
        forced_height = dpi(25),
        forced_width = dpi(20),
        shape = utilities.widgets.mkroundedrect(),
        widget = wibox.container.background,
    }

    local actions = wibox.widget({
        notification = n,
        base_layout = wibox.widget({
            spacing = dpi(8),
            layout = wibox.layout.flex.horizontal,
        }),
        widget_template = action_widget,
        style = { underline_normal = false, underline_selected = true },
        widget = naughty.list.actions,
    })

    naughty.layout.box({
        notification = n,
        type = "notification",
        bg = beautiful.bg_normal .. 00,
        widget_template = {
            {
                {
                    {
                        {
                            {
                                {
                                    {
                                        {
                                            {
                                                image = appicon,
                                                resize = true,
                                                clip_shape = utilities.widgets.mkroundedrect(),
                                                widget = wibox.widget.imagebox,
                                            },
                                            strategy = "max",
                                            height = dpi(20),
                                            widget = wibox.container.constraint,
                                        },
                                        margins = dpi(5),
                                        widget = wibox.container.margin,
                                    },
                                    widget = wibox.container.background,
                                },
                                {
                                    {
                                        {
                                            {
                                                markup = n.app_name,
                                                align = "left",
                                                font = beautiful.title_font,
                                                widget = wibox.widget.textbox,
                                            },
                                            left = dpi(10),
                                            top = dpi(5),
                                            bottom = dpi(5),
                                            widget = wibox.container.margin,
                                        },
                                        {
                                            {
                                                markup = time,
                                                align = "right",
                                                font = beautiful.font,
                                                widget = wibox.widget.textbox,
                                            },
                                            right = dpi(10),
                                            top = dpi(5),
                                            bottom = dpi(5),
                                            widget = wibox.container.margin,
                                        },
                                        layout = wibox.layout.flex.horizontal,
                                    },
                                    bg = beautiful.bg_normal,
                                    widget = wibox.container.background,
                                },
                                layout = wibox.layout.align.horizontal,
                            },
                            top = dpi(0),
                            left = dpi(0),
                            right = dpi(0),
                            bottom = dpi(0),
                            widget = wibox.container.margin,
                        },
                        bg = beautiful.bg_normal,
                        widget = wibox.container.background,
                    },
                    {
                        bg = beautiful.black .. "88",
                        forced_height = dpi(0),
                        widget = wibox.container.background,
                    },
                    {
                        {
                            {
                                utilities.visual.vertical_pad(5),
                                {
                                    {
                                        step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
                                        speed = 50,
                                        {
                                            markup = "<span weight='bold'>"
                                                .. n.title
                                                .. "</span>",
                                            font = beautiful.title_font
                                                .. " 18",
                                            align = "left",
                                            widget = wibox.widget.textbox,
                                        },
                                        forced_width = dpi(204),
                                        widget = wibox.container.scroll.horizontal,
                                    },
                                    {
                                        {
                                            markup = n.message,
                                            align = "left",
                                            font = beautiful.title_font
                                                .. " 10",
                                            widget = wibox.widget.textbox,
                                        },
                                        right = 10,
                                        widget = wibox.container.margin,
                                    },
                                    spacing = 0,
                                    layout = wibox.layout.flex.vertical,
                                },
                                utilities.visual.vertical_pad(5),
                                layout = wibox.layout.align.vertical,
                            },
                            left = dpi(20),
                            right = dpi(20),
                            widget = wibox.container.margin,
                        },
                        {
                            {
                                {
                                    {
                                        image = n.icon,
                                        resize = true,
                                        clip_shape = utilities.widgets.mkroundedrect(),
                                        widget = wibox.widget.imagebox,
                                    },
                                    strategy = "max",
                                    height = dpi(80),
                                    widget = wibox.container.constraint,
                                },
                                valign = "center",
                                widget = wibox.container.place,
                            },
                            top = dpi(10),
                            left = dpi(10),
                            right = dpi(10),
                            bottom = dpi(10),
                            widget = wibox.container.margin,
                        },
                        layout = wibox.layout.fixed.horizontal,
                    },
                    {
                        { actions, layout = wibox.layout.fixed.vertical },
                        margins = dpi(10),
                        visible = n.actions and #n.actions > 0,
                        widget = wibox.container.margin,
                    },
                    layout = wibox.layout.fixed.vertical,
                },
                top = dpi(0),
                bottom = dpi(5),
                widget = wibox.container.margin,
            },
            bg = beautiful.bg_normal .. "88",
            border_width = dpi(0.25),
            border_color = beautiful.grey,
            shape = utilities.widgets.mkroundedrect(),
            widget = wibox.container.background,
        },
    })
end)
