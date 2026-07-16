--- Notification widget rendering.
-- Pure UI functions for building notification display widgets and action buttons.
-- Takes notification data as parameters and returns widgets.
-- @module ui.popups.control_panel.notification_list.widget

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gcolor = require("gears.color")
local modules = require("modules")
local dpi = beautiful.xresources.apply_dpi
local create_markup = require("lib.util").create_markup
local shapes = require("modules.style.shapes")

local gfs = require("gears.filesystem")
local icons_dir = gfs.get_configuration_dir()
    .. "ui/popups/control_panel/notification_list/icons/"
local close_icon = icons_dir .. "close.svg"

local FONT_NAME = beautiful.font_name or "Sans "

local widget = {}

--- Create action buttons widget for a notification.
-- @tparam table n Naughty notification object with `.actions` array
-- @treturn wibox.widget|nil A widget with clickable action buttons, or nil
function widget.create_actions_widget(n)
    if not n.actions or #n.actions == 0 then
        return nil
    end

    local actions_widget = wibox.widget({
        widget = wibox.container.margin,
        margins = { top = dpi(5) },
        {
            id = "main-layout",
            layout = wibox.layout.flex.horizontal,
            spacing = dpi(5),
        },
    })

    local main_layout = actions_widget:get_children_by_id("main-layout")[1]
    for _, action in ipairs(n.actions) do
        main_layout:add(wibox.widget({
            widget = wibox.container.constraint,
            strategy = "max",
            height = dpi(40),
            {
                widget = modules.hover_button({
                    label = action.name,
                    font = beautiful.font_h0,
                    margins = {
                        left = dpi(10),
                        right = dpi(10),
                        top = dpi(8),
                        bottom = dpi(8),
                    },
                    shape = shapes.rrect(8),
                    buttons = {
                        awful.button({}, 1, function()
                            action:invoke()
                        end),
                    },
                }),
            },
        }))
    end

    return actions_widget
end

--- Create a single notification widget for the list.
-- Shows app name, timestamp, icon, title, body text, and action buttons.
-- @tparam table n Naughty notification object
-- @tparam table notification_list_widget The parent notification list
-- @tparam string notification_id Unique ID for identification/removal
-- @tparam function remove_callback Callback to remove the notification by ID
-- @treturn wibox.widget The notification display widget
function widget.create_notification_widget(
    n,
    notification_list_widget,
    notification_id,
    remove_callback
)
    local w = wibox.widget({
        is_notification = true,
        notification_id = notification_id,
        widget = wibox.container.constraint,
        strategy = "max",
        height = 260,
        {
            widget = wibox.container.background,
            bg = beautiful.bg_alt,
            shape = shapes.rrect(10),
            {
                widget = wibox.container.margin,
                margins = dpi(15),
                {
                    layout = wibox.layout.fixed.vertical,
                    spacing = dpi(5),
                    {
                        layout = wibox.layout.align.horizontal,
                        {
                            widget = wibox.container.constraint,
                            strategy = "max",
                            width = dpi(150),
                            height = dpi(25),
                            {
                                widget = wibox.widget.textbox,
                                markup = create_markup(n.app_name, {
                                    fg = n.urgency == "critical"
                                            and beautiful.red
                                        or beautiful.fg,
                                }),
                            },
                        },
                        nil,
                        {
                            layout = wibox.layout.fixed.horizontal,
                            spacing = dpi(10),
                            {
                                widget = wibox.widget.textbox,
                                markup = create_markup(
                                    n.timestamp
                                            and os.date("%H:%M", n.timestamp)
                                        or os.date("%H:%M"),
                                    { fg = beautiful.fg_alt }
                                ),
                            },
                            {
                                id = "close",
                                widget = wibox.container.background,
                                bg = "transparent",
                                buttons = {
                                    awful.button({}, 1, function()
                                        local success, err = pcall(function()
                                            if notification_id then
                                                local cache = require(
                                                    "ui.notification.cache"
                                                )
                                                cache.remove(notification_id)
                                            end
                                            if remove_callback then
                                                remove_callback(
                                                    notification_list_widget,
                                                    notification_id
                                                )
                                            end
                                        end)
                                        if not success then
                                            print(
                                                "ERROR: Error removing notification:",
                                                err
                                            )
                                        end
                                    end),
                                },
                                {
                                    widget = wibox.container.margin,
                                    margins = dpi(4),
                                    {
                                        widget = wibox.widget.imagebox,
                                        image = gcolor.recolor_image(
                                            close_icon,
                                            beautiful.red
                                        ),
                                        resize = true,
                                        forced_width = dpi(16),
                                        forced_height = dpi(16),
                                    },
                                },
                            },
                        },
                    },
                    {
                        widget = wibox.container.background,
                        forced_width = 1,
                        forced_height = beautiful.separator_thickness,
                        {
                            widget = wibox.widget.separator,
                            orientation = "horizontal",
                        },
                    },
                    {
                        layout = wibox.layout.fixed.horizontal,
                        fill_space = true,
                        spacing = dpi(10),
                        {
                            widget = wibox.container.constraint,
                            strategy = "max",
                            width = dpi(70),
                            height = dpi(70),
                            {
                                widget = wibox.widget.imagebox,
                                resize = true,
                                halign = "center",
                                valign = "top",
                                clip_shape = shapes.rrect(dpi(5)),
                                image = n.icon,
                            },
                        },
                        {
                            layout = wibox.layout.fixed.vertical,
                            spacing = dpi(5),
                            {
                                widget = wibox.container.constraint,
                                strategy = "max",
                                height = dpi(25),
                                {
                                    widget = wibox.widget.textbox,
                                    markup = n.title,
                                },
                            },
                            {
                                widget = wibox.container.constraint,
                                strategy = "max",
                                height = dpi(80),
                                {
                                    widget = wibox.widget.textbox,
                                    font = FONT_NAME .. dpi(9),
                                    markup = n.text or n.massage,
                                },
                            },
                        },
                    },
                    widget.create_actions_widget(n),
                },
            },
        },
    })

    return w
end

return widget
