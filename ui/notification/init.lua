local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local gears = require("gears")
local modules = require("modules")
local beautiful = require("beautiful")
local shapes = require("modules.shapes")
local ncr = naughty.notification_closed_reason
local dpi = beautiful.xresources.apply_dpi
local create_markup = require("lib").create_markup
local remove_nonindex = require("lib").remove_nonindex

local notifications = {}

local function update_positions(screen)
    if #screen.notifications > 0 then
        for i = 1, #screen.notifications do
            screen.notifications[i]:geometry({
                x = screen.workarea.x
                    + screen.workarea.width
                    - beautiful.notification_margins
                    - screen.notifications[i].width,
                y = i > 1
                        and screen.notifications[i - 1].y + screen.notifications[i - 1].height + beautiful.notification_spacing
                    or screen.workarea.y + beautiful.notification_margins,
            })
        end
    end
end

local function add_popup(popup, screen)
    if not popup then
        return
    end
    table.insert(screen.notifications, 1, popup)
    popup.visible = true
    update_positions(screen)
end

local function remove_popup(popup, screen)
    if not popup then
        return
    end
    remove_nonindex(screen.notifications, popup)
    popup.visible = false
    popup = nil
    update_positions(screen)
end

local function create_actions_widget(n)
    if #n.actions == 0 then
        return nil
    end

    -- Use a clean horizontal layout for the action buttons
    local layout_widget = wibox.widget({
        layout = wibox.layout.flex.horizontal,
        spacing = dpi(5),
    })

    for _, action in ipairs(n.actions) do
        layout_widget:add(wibox.widget({
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
                    shape = shapes.rrect_8,
                    buttons = {
                        awful.button({}, 1, function()
                            action:invoke()
                        end),
                    },
                }),
            },
        }))
    end

    return wibox.widget({
        widget = wibox.container.margin,
        margins = { top = dpi(10) },
        layout_widget,
    })
end

local function create_notification_popup(n)
    local popup_widget = awful.popup({
        type = "notification",
        screen = n.screen,
        visible = false,
        ontop = true,
        -- Remove fixed height constraints to allow dynamic sizing
        minimum_width = dpi(400),
        maximum_width = dpi(450),
        bg = "#00000000",
        placement = function()
            return { 0, 0 }
        end,
        widget = {
            widget = wibox.container.background,
            bg = beautiful.bg,
            fg = beautiful.fg,
            border_color = beautiful.border_color_normal,
            border_width = beautiful.border_width,
            shape = shapes.rrect_20,
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
                                    os.date("%H:%M"),
                                    { fg = beautiful.fg_alt }
                                ),
                            },
                            {
                                {
                                    id = "close",
                                    widget = wibox.widget.imagebox,
                                    image = gears.color.recolor_image(
                                        beautiful.titlebar_icons.close,
                                        beautiful.fg
                                    ),
                                    forced_width = dpi(12),
                                    forced_height = dpi(12),
                                },
                                widget = wibox.container.margin,
                                margins = dpi(1),
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
                        buttons = {
                            awful.button({}, 1, function()
                                n:destroy(ncr.dismissed_by_user)
                            end),
                        },
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
                                    font = beautiful.font_name .. dpi(9),
                                    markup = n.text or n.massage,
                                },
                            },
                        },
                    },
                    create_actions_widget(n),
                },
            },
        },
    })

    local close = popup_widget.widget:get_children_by_id("close")[1]
    close:buttons({
        awful.button({}, 1, function()
            n:destroy(ncr.silent)
        end),
    })

    return popup_widget
end

function notifications.display(n)
    if not n then
        return
    end
    local notification_popup = create_notification_popup(n)
    local display_timer

    -- Only create a timer if the notification has a timeout > 0
    if n.timeout > 0 then
        display_timer = gtimer({
            timeout = n.timeout,
            callback = function()
                remove_popup(notification_popup, n.screen)
            end,
        })
    end

    n:connect_signal("destroyed", function()
        if display_timer then
            display_timer:stop()
        end
        display_timer = nil
        remove_popup(notification_popup, n.screen)
    end)

    add_popup(notification_popup, n.screen)

    if display_timer then
        display_timer:start()
    end
end

local function new()
    local ret = {}
    gtable.crush(ret, notifications, true)

    awful.screen.connect_for_each_screen(function(s)
        s.notifications = {}
    end)

    return ret
end

local instance = nil
local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return {
    get_default = get_default,
}
