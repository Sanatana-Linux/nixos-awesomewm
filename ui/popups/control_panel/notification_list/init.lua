--- Notification list widget for the control panel.
-- Renders naughty notifications in a scrollable list. Supports do-not-disturb
-- mode, per-notification removal, and a "clear all" confirmation dialog.
-- Delegates widget rendering to `widget.lua` and confirmation dialog to
-- `dialog.lua`.
-- @module ui.popups.control_panel.notification_list

local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local gfs = require("gears.filesystem")
local gcolor = require("gears.color")
local modules = require("modules")
local shapes = require("modules.style.shapes")
local notifications_service = require("ui.notification").get_default()

local widget_module =
    require("ui.popups.control_panel.notification_list.widget")
local dialog_module =
    require("ui.popups.control_panel.notification_list.dialog")

local overflow = require("wibox.layout.overflow")
local dpi = beautiful.xresources.apply_dpi

local icons_dir = gfs.get_configuration_dir()
    .. "ui/popups/control_panel/notification_list/icons/"
local bell_on_icon = icons_dir .. "bell-on.svg"
local bell_off_icon = icons_dir .. "bell-off.svg"
local trash_icon = icons_dir .. "trash.svg"
local close_icon = icons_dir .. "close.svg"

-- Safe font name with fallback (font_name can be nil if theme not fully loaded)
local FONT_NAME = beautiful.font_name or "Sans "

local notification_list = {}

--- Remove a notification widget by its ID from the layout.
-- @tparam table self The notification list widget
-- @tparam number|string notification_id The notification to remove
-- @local
local function remove_notification_by_id(self, notification_id)
    local success, err = pcall(function()
        local notifs_layout = self:get_children_by_id("notifications-layout")[1]
        if not notifs_layout then
            print("ERROR: notifications-layout not found")
            return
        end

        -- Find widget with matching notification ID
        local widget_to_remove = nil
        for i, child in ipairs(notifs_layout.children or {}) do
            if
                child.is_notification
                and child.notification_id == notification_id
            then
                widget_to_remove = child
                break
            end
        end

        if widget_to_remove then
            notifs_layout:remove_widgets(widget_to_remove)
        else
            print(
                "WARNING: Widget with notification ID not found:",
                notification_id
            )
            return
        end

        -- Check if we need to add the "No notifications" message
        if #notifs_layout.children == 0 then
            notifs_layout:insert(
                1,
                wibox.widget({
                    widget = wibox.container.background,
                    fg = beautiful.fg_alt,
                    forced_height = dpi(560),
                    {
                        widget = wibox.widget.textbox,
                        align = "center",
                        font = FONT_NAME .. dpi(12),
                        markup = "No notifications",
                    },
                })
            )
        end

        self:update_count()
    end)

    if not success then
        print("ERROR: Error removing notification:", err)
    end
end

--- Add a notification to the list widget.
-- Inserts at index 1 (newest first). Removes "No notifications" placeholder
-- if it exists.
-- @tparam table self The notification list widget
-- @tparam table n Naughty notification object
-- @local
local function add_notification(self, n)
    if not n then
        return
    end
    local notifs_layout = self:get_children_by_id("notifications-layout")[1]

    -- Generate ID if it doesn't exist
    local notification_id = n.id
        or tostring(os.time() .. math.random(1000, 9999))

    local new_notification_widget = widget_module.create_notification_widget(
        n,
        self,
        notification_id,
        remove_notification_by_id
    )
    if
        #notifs_layout.children == 1
        and not notifs_layout.children[1].is_notification
    then
        notifs_layout:reset()
    end
    notifs_layout:insert(1, new_notification_widget)
    self:update_count()
end

--- Clear all notifications after user confirmation.
-- Removes all notification widgets from the layout, resets the count,
-- and clears the on-disk cache file.
function notification_list:clear_notifications()
    -- Create confirmation dialog
    local dialog = dialog_module.create_confirmation_dialog(function()
        -- Clear the visual notifications first
        local notifs_layout = self:get_children_by_id("notifications-layout")[1]
        local notification_widgets = {}

        -- Collect all notification widgets to remove
        for _, widget in ipairs(notifs_layout.children) do
            if widget.is_notification then
                table.insert(notification_widgets, widget)
            end
        end

        -- Remove widgets one by one safely
        for _, widget in ipairs(notification_widgets) do
            notifs_layout:remove_widgets(widget)
        end

        -- Add "No notifications" message if list is empty
        if #notifs_layout.children == 0 then
            notifs_layout:insert(
                1,
                wibox.widget({
                    widget = wibox.container.background,
                    fg = beautiful.fg_alt,
                    forced_height = dpi(560),
                    {
                        widget = wibox.widget.textbox,
                        align = "center",
                        font = FONT_NAME .. dpi(12),
                        markup = "No notifications",
                    },
                })
            )
        end

        self:update_count()

        -- Clear the notification cache safely
        local cache_success = pcall(function()
            local cache_file = os.getenv("HOME")
                .. "/.cache/awesome/notifications.json"
            local file = io.open(cache_file, "w")
            if file then
                file:write("[]")
                file:close()
            else
                print("Failed to open cache file for writing")
            end
        end)

        if not cache_success then
            print("Failed to clear notification cache")
        end
    end)

    dialog.show()
end

--- Update the notification count badge.
-- Reads the number of notification children and updates the title label.
function notification_list:update_count()
    local notifs_layout = self:get_children_by_id("notifications-layout")[1]
    local notifs_title = self:get_children_by_id("notifications-title")[1]
    if
        #notifs_layout.children > 0
        and notifs_layout.children[1].is_notification
    then
        notifs_title:set_markup(
            string.format("Notifications (%s)", #notifs_layout.children)
        )
    else
        notifs_title:set_markup("Notifications")
    end
end

--- Toggle Do Not Disturb mode.
-- Suspends or resumes naughty notifications and updates the DND icon.
function notification_list:toggle_dnd()
    local wp = self._private
    wp.dnd_mode = not wp.dnd_mode
    if wp.dnd_mode then
        naughty.suspend()
    else
        naughty.resume()
    end
end

--- Construct a new notification list widget.
-- Creates the scrollable layout, wires DND and clear buttons, loads cached
-- notifications from disk, and connects to naughty's `added` signal.
-- @treturn wibox.widget The notification list widget
-- @local
local function new()
    local ret = wibox.widget({
        widget = wibox.container.background,
        forced_height = dpi(50) + dpi(560),
        forced_width = dpi(450),
        {
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(6),
            {
                widget = wibox.container.background,
                forced_height = dpi(40),
                {
                    layout = wibox.layout.align.horizontal,
                    {
                        widget = wibox.container.margin,
                        margins = { left = dpi(7) },
                        {
                            id = "notifications-title",
                            widget = wibox.widget.textbox,
                            align = "center",
                            markup = "Notifications",
                        },
                    },
                    nil,
                    {
                        layout = wibox.layout.fixed.horizontal,
                        spacing = beautiful.separator_thickness + dpi(2),
                        spacing_widget = {
                            widget = wibox.container.margin,
                            margins = { top = dpi(8), bottom = dpi(8) },
                            {
                                widget = wibox.widget.separator,
                                orientation = "vertical",
                            },
                        },
                        {
                            id = "dnd-button",
                            widget = modules.hover_button({
                                bg_normal = beautiful.bg,
                                margins = {
                                    right = dpi(11),
                                    left = dpi(11),
                                },
                                shape = shapes.rrect(10),
                                forced_height = dpi(36),
                                forced_width = dpi(42),
                                child_widget = {
                                    widget = wibox.container.place,
                                    halign = "center",
                                    valign = "center",
                                    {
                                        id = "dnd-icon",
                                        widget = wibox.widget.imagebox,
                                        image = gcolor.recolor_image(
                                            bell_on_icon,
                                            beautiful.fg
                                        ),
                                        resize = true,
                                        forced_width = dpi(20),
                                        forced_height = dpi(20),
                                    },
                                },
                            }),
                        },
                        {
                            id = "clear-button",
                            widget = modules.hover_button({
                                fg_normal = beautiful.red,
                                bg_normal = beautiful.bg,
                                bg_hover = beautiful.red,
                                margins = {
                                    right = dpi(11),
                                    left = dpi(11),
                                },
                                shape = shapes.rrect(10),
                                forced_height = dpi(36),
                                forced_width = dpi(42),
                                icon_source = trash_icon,
                                icon_normal_color = beautiful.red,
                                icon_hover_color = beautiful.bg,
                                child_widget = {
                                    widget = wibox.container.place,
                                    halign = "center",
                                    valign = "center",
                                    {
                                        widget = wibox.widget.imagebox,
                                        image = gcolor.recolor_image(
                                            trash_icon,
                                            beautiful.red
                                        ),
                                        resize = true,
                                        forced_width = dpi(20),
                                        forced_height = dpi(20),
                                    },
                                },
                            }),
                        },
                    },
                },
            },
            {
                id = "notifications-layout",
                layout = overflow.vertical,
                scrollbar_enabled = false,
                step = 80,
                spacing = dpi(6),
            },
        },
    })

    gtable.crush(ret, notification_list, true)
    local wp = ret._private

    wp.dnd_mode = false

    local dnd_button = ret:get_children_by_id("dnd-button")[1]
    dnd_button:buttons({
        awful.button({}, 1, function()
            ret:toggle_dnd()
            local icon = dnd_button:get_children_by_id("dnd-icon")[1]
            if wp.dnd_mode then
                icon.image = gcolor.recolor_image(bell_off_icon, beautiful.fg)
            else
                icon.image = gcolor.recolor_image(bell_on_icon, beautiful.fg)
            end
        end),
    })

    local clear_button = ret:get_children_by_id("clear-button")[1]
    clear_button:buttons({
        awful.button({}, 1, function()
            ret:clear_notifications()
        end),
    })

    local notifs_layout = ret:get_children_by_id("notifications-layout")[1]
    notifs_layout:insert(
        1,
        wibox.widget({
            widget = wibox.container.background,
            fg = beautiful.fg_alt,
            forced_height = dpi(560),
            {
                widget = wibox.widget.textbox,
                align = "center",
                font = FONT_NAME .. dpi(12),
                markup = "No notifications",
            },
        })
    )

    -- Load cached notifications after a brief delay to avoid initialization issues
    local gtimer = require("gears.timer")
    gtimer.delayed_call(function()
        local cached_notifications =
            notifications_service:get_cached_notifications()
        if cached_notifications and #cached_notifications > 0 then
            -- Remove the "No notifications" placeholder
            notifs_layout:reset()
            -- Add cached notifications (newest first since cache is already in that order)
            for _, cached_notif in ipairs(cached_notifications) do
                -- Create notification widget from cached data
                local cached_widget = widget_module.create_notification_widget(
                    cached_notif,
                    ret,
                    cached_notif.id,
                    remove_notification_by_id
                )
                notifs_layout:add(cached_widget)
            end
            ret:update_count()
        end
    end)

    naughty.connect_signal("added", function(n)
        add_notification(ret, n)
    end)

    return ret
end

return setmetatable({
    new = new,
}, {
    __call = new,
})
