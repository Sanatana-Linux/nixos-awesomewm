--- Unified notification system.
-- Replaces the default naughty notification display with a themed popup.
-- Subscribes to the `naughty` request signals to intercept error display,
-- notification display, and notification rules. Maintains a small cache of
-- recent notifications (`ui.notification.cache`) so duplicate notifications
-- don't pile up. Backs the `Mod4+;` toggle keybinding (`system.lua`).
-- @module ui.notification

local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local gears = require("gears")
local gcolor = require("gears.color")
local gfs = require("gears.filesystem")
local modules = require("modules")
local beautiful = require("beautiful")
local shapes = require("modules.style.shapes")
local ncr = naughty.notification_closed_reason
local capi = { awesome = awesome }
local dpi = beautiful.xresources.apply_dpi
local create_markup = require("lib.util").create_markup
local remove_nonindex = require("lib.util").remove_nonindex
local notification_cache = require("ui.notification.cache")

local close_icon = gfs.get_configuration_dir() .. "ui/titlebar/icons/close.svg"

capi.awesome.connect_signal("exit", function()
    naughty.destroy_all_notifications(nil, ncr.silent)
end)

require("ui.notification.battery")

local notifications = {}

--- Reposition all of a screen's notification popups (stacked, top-right).
-- Called after add/remove/expire to keep the column flush.
-- @tparam screen screen The screen whose notifications to re-layout
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

--- Add a popup to the top of a screen's notification stack.
-- @tparam popup popup The notification popup widget
-- @tparam screen screen The screen to display on
local function add_popup(popup, screen)
    if not popup then
        return
    end
    table.insert(screen.notifications, 1, popup)
    popup.visible = true
    update_positions(screen)
end

--- Remove a popup from a screen's notification stack.
-- @tparam popup popup The notification popup widget
-- @tparam screen screen The screen to remove from
local function remove_popup(popup, screen)
    if not popup then
        return
    end
    remove_nonindex(screen.notifications, popup)
    popup.visible = false
    popup = nil
    update_positions(screen)
end

--- Build the per-notification action button row.
-- Returns nil when `n` has no actions. Each action becomes a
-- `hover_button` with click-handler that invokes the action.
-- @tparam naughty.notification n
-- @treturn table|nil A wibox widget for the action row, or nil
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

--- Build the popup widget for a single notification.
-- Includes the app name + timestamp header, a close button, an
-- icon, title, body, and the actions row. The widget is hidden
-- initially and added to the screen's stack by `display()`.
-- @tparam naughty.notification n
-- @treturn table A wibox widget
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
            bg = beautiful.bg .. "99",
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
                                    {
                                        id = "close",
                                        image = gears.color.recolor_image(
                                            close_icon,
                                            beautiful.fg
                                        ),
                                        resize = true,
                                        forced_width = dpi(10),
                                        forced_height = dpi(10),
                                        align = "center",
                                        valign = "center",
                                        widget = wibox.widget.imagebox,
                                    },
                                    left = dpi(4),
                                    right = dpi(4),
                                    widget = wibox.container.margin,
                                },
                                shape = shapes.rrect(2),
                                border_width = dpi(1),
                                border_color = beautiful.fg_alt .. "aa",
                                bg = beautiful.bg_gradient_button,
                                id = "close_bg",
                                widget = wibox.container.background,
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
    local close_bg = popup_widget.widget:get_children_by_id("close_bg")[1]
    close_bg:add_button(awful.button({}, 1, function()
        n:destroy(ncr.silent)
    end))
    close_bg:connect_signal("mouse::enter", function()
        -- Red gradient background like power menu toggle
        close_bg.bg = "linear:0,0:0,32:0,"
            .. beautiful.red
            .. ":1,"
            .. "#b61442"
        -- Change icon to white
        close.image = gcolor.recolor_image(close_icon, beautiful.bg)
    end)
    close_bg:connect_signal("mouse::leave", function()
        close_bg.bg = beautiful.bg_gradient_button
        -- Revert icon to red
        close.image = gcolor.recolor_image(close_icon, beautiful.red)
    end)

    return popup_widget
end

--- Display a naughty notification `n` as a themed popup. Caches it so the
-- notification center can show history. Idempotent for `n == nil`.
-- @tparam naughty.notification n
function notifications.display(n)
    if not n then
        return
    end

    -- Cache the notification
    notification_cache.add(n)

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

-- Expose cache functions for use by other modules
--- @treturn table All cached notifications
function notifications.get_cached_notifications()
    return notification_cache.get_all()
end

--- Clear the notification cache.
function notifications.clear_cache()
    return notification_cache.clear()
end

--- @treturn integer Number of notifications currently cached
function notifications.get_cache_count()
    return notification_cache.count()
end

--- Construct the notification service instance.
-- Initialises per-screen `notifications` arrays via
-- `awful.screen.connect_for_each_screen`.
-- @treturn table Service instance with display/cache methods
local function new()
    local ret = {}
    gtable.crush(ret, notifications, true)

    awful.screen.connect_for_each_screen(function(s)
        s.notifications = {}
    end)

    return ret
end

local instance = nil
--- Singleton accessor: returns (and lazily constructs) the notification service.
-- @treturn table Cached service instance (same object on every call)
local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return {
    get_default = get_default,
}
