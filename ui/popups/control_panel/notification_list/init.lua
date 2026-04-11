local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local gfs = require("gears.filesystem")
local gcolor = require("gears.color")
local modules = require("modules")
local ncr = naughty.notification_closed_reason
local dpi = beautiful.xresources.apply_dpi
local create_markup = require("lib").create_markup
local shapes = require("modules.shapes")
local notifications_service = require("ui.notification").get_default()

local icons_dir = gfs.get_configuration_dir()
    .. "ui/popups/control_panel/notification_list/icons/"
local bell_on_icon = icons_dir .. "bell-on.svg"
local bell_off_icon = icons_dir .. "bell-off.svg"
local trash_icon = icons_dir .. "trash.svg"
local close_icon = icons_dir .. "close.svg"

local notification_list = {}

local function create_actions_widget(n)
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
                    margins = {
                        left = dpi(10),
                        right = dpi(10),
                        top = dpi(5),
                        bottom = dpi(5),
                    },
                    bg_normal = beautiful.bg_urg,
                    shape = shapes.rrect(10),
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

local function create_notification_widget(n, notification_list_widget, notification_id)
    local widget = wibox.widget({
        is_notification = true,
        notification_id = notification_id, -- Store ID for removal
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
                                    n.timestamp and os.date("%H:%M", n.timestamp) or os.date("%H:%M"),
                                    { fg = beautiful.fg_alt }
                                ),
                            },
                            {
                                id = "close",
                                widget = wibox.container.background,
                                bg = "transparent",
                                buttons = {
                                    awful.button({}, 1, function()
                                        print("DEBUG: SIMPLE CLOSE BUTTON CLICKED for notification:", notification_id)
                                        print("DEBUG: notification_list_widget type:", type(notification_list_widget))
                                        print("DEBUG: widget type:", type(widget))
                                        
                                        -- Remove this specific notification from the center and cache safely
                                        local success, err = pcall(function()
                                            print("DEBUG: Starting cache removal")
                                            if notification_id then
                                                local cache = require("ui.notification.cache")
                                                local cache_result = cache.remove(notification_id)
                                                print("DEBUG: Cache removal result:", cache_result)
                                            end
                                            print("DEBUG: Starting widget removal")
                                            remove_notification(notification_list_widget, widget)
                                            print("DEBUG: Widget removal completed")
                                        end)
                                        if not success then
                                            print("ERROR: Error removing notification:", err)
                                        else
                                            print("DEBUG: Successfully removed notification")
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
                        -- Remove the buttons from here to avoid duplicate handlers
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

    return widget
end

local function remove_notification(self, w)
    print("DEBUG: remove_notification called")
    print("DEBUG: self type:", type(self))
    print("DEBUG: w type:", type(w))
    
    local success, err = pcall(function()
        print("DEBUG: Getting notifications-layout")
        local notifs_layout = self:get_children_by_id("notifications-layout")[1]
        if not notifs_layout then
            print("ERROR: notifications-layout not found")
            return
        end
        print("DEBUG: notifications-layout found, children count:", #notifs_layout.children)
        
        -- Check if widget exists in the layout before removing
        local found = false
        for i, child in ipairs(notifs_layout.children or {}) do
            print("DEBUG: Checking child", i, "type:", type(child))
            if child == w then
                found = true
                print("DEBUG: Found widget at index", i)
                break
            end
        end
        
        if found then
            print("DEBUG: Removing widget from layout")
            notifs_layout:remove_widgets(w)
            print("DEBUG: Successfully removed notification widget")
        else
            print("WARNING: Widget not found in layout, skipping removal")
        end
        
        -- Check if we need to add the "No notifications" message
        print("DEBUG: Checking if we need 'No notifications' message, children count:", #notifs_layout.children)
        if #notifs_layout.children == 0 then
            print("DEBUG: Adding 'No notifications' message")
            notifs_layout:insert(
                1,
                wibox.widget({
                    widget = wibox.container.background,
                    fg = beautiful.fg_alt,
                    forced_height = dpi(560),
                    {
                        widget = wibox.widget.textbox,
                        align = "center",
                        font = beautiful.font_name .. dpi(12),
                        markup = "No notifications",
                    },
                })
            )
        end
        
        print("DEBUG: Calling update_count")
        self:update_count()
        print("DEBUG: update_count completed")
    end)
    
    if not success then
        print("ERROR: Error in remove_notification function:", err)
    else
        print("DEBUG: remove_notification completed successfully")
    end
end

local function add_notification(self, n)
    if not n then
        return
    end
    local notifs_layout = self:get_children_by_id("notifications-layout")[1]
    
    -- Generate ID if it doesn't exist
    local notification_id = n.id or tostring(os.time() .. math.random(1000, 9999))
    
    local new_notification_widget = create_notification_widget(n, self, notification_id)
    if
        #notifs_layout.children == 1
        and not notifs_layout.children[1].is_notification
    then
        notifs_layout:reset()
    end
    notifs_layout:insert(1, new_notification_widget)
    -- NOTE: Removed the destroyed signal connection here so notifications
    -- persist in the notification center after disappearing from screen
    self:update_count()
end

-- Create confirmation dialog for clearing notifications
local function create_confirmation_dialog(callback)
    local screen = awful.screen.focused()
    
    local backdrop = wibox({
        visible = false,
        ontop = false,
        type = "desktop",
        bg = "#00000088",
        x = screen.geometry.x,
        y = screen.geometry.y,
        width = screen.geometry.width,
        height = screen.geometry.height,
    })
    
    -- Define dialog functions first
    local dialog_functions = {}
    
    local function hide_dialog()
        backdrop.visible = false
        if dialog_functions.dialog then
            dialog_functions.dialog.visible = false
        end
    end
    
    local function handle_cancel()
        print("Cancel button clicked")
        hide_dialog()
    end
    
    local function handle_clear_all()
        print("DEBUG: Clear All button clicked")
        hide_dialog()
        if callback then
            print("DEBUG: Calling callback function")
            callback()
        else
            print("ERROR: No callback function provided")
        end
    end
    
    -- Create cancel button
    local cancel_button = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg_alt,
        shape = shapes.rrect(8),
        buttons = {
            awful.button({}, 1, handle_cancel)
        },
        {
            widget = wibox.container.margin,
            margins = {
                left = dpi(15),
                right = dpi(15),
                top = dpi(8),
                bottom = dpi(8),
            },
            {
                widget = wibox.widget.textbox,
                align = "center",
                markup = "Cancel",
                font = beautiful.font_name .. " " .. dpi(10),
            },
        },
    })
    
    -- Create clear all button
    local clear_button = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.red,
        shape = shapes.rrect(8),
        buttons = {
            awful.button({}, 1, handle_clear_all)
        },
        {
            widget = wibox.container.margin,
            margins = {
                left = dpi(15),
                right = dpi(15),
                top = dpi(8),
                bottom = dpi(8),
            },
            {
                widget = wibox.widget.textbox,
                align = "center",
                markup = create_markup("Clear All", { fg = beautiful.bg }),
                font = beautiful.font_name .. " " .. dpi(10),
            },
        },
    })
    
    -- Don't add button functionality separately since it's already in the widget definition
    
    local dialog = awful.popup({
        visible = false,
        ontop = true,
        type = "dialog",
        screen = screen,
        bg = "#00000000",
        placement = awful.placement.centered,
        forced_width = dpi(350),
        widget = {
            widget = wibox.container.background,
            bg = beautiful.bg,
            border_width = dpi(2),
            border_color = beautiful.fg_alt,
            shape = shapes.rrect(15),
            {
                widget = wibox.container.margin,
                margins = dpi(20),
                {
                    layout = wibox.layout.fixed.vertical,
                    spacing = dpi(15),
                    -- Title
                    {
                        widget = wibox.widget.textbox,
                        align = "center",
                        markup = create_markup("Clear All Notifications", {
                            size = dpi(14),
                            weight = "bold",
                        }),
                    },
                    -- Message
                    {
                        widget = wibox.widget.textbox,
                        align = "center",
                        markup = create_markup(
                            "This will permanently delete all notification history.\nAre you sure you want to continue?",
                            {
                                fg = beautiful.fg_alt,
                                size = dpi(12),
                            }
                        ),
                    },
                    -- Buttons
                    {
                        layout = wibox.layout.flex.horizontal,
                        spacing = dpi(10),
                        cancel_button,
                        clear_button,
                    },
                },
            },
        },
    })
    
    dialog_functions.dialog = dialog
    
    -- Hide dialog when clicking backdrop
    backdrop.buttons = {
        awful.button({}, 1, hide_dialog)
    }
    
    return {
        show = function()
            print("Showing confirmation dialog")
            backdrop.visible = true
            dialog.visible = true
        end,
        hide = hide_dialog
    }
end

function notification_list:clear_notifications()
    -- Create confirmation dialog
    local dialog = create_confirmation_dialog(function()
        print("Clear all button clicked - starting clearing process")
        
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
                        font = beautiful.font_name .. dpi(12),
                        markup = "No notifications",
                    },
                })
            )
        end
        
        self:update_count()
        
        -- Clear the notification cache safely
        local cache_success = pcall(function()
            local cache_file = os.getenv("HOME") .. "/.cache/awesome/notifications.json"
            local file = io.open(cache_file, "w")
            if file then
                file:write("[]")
                file:close()
                print("Successfully cleared notification cache")
            else
                print("Failed to open cache file for writing")
            end
        end)
        
        if not cache_success then
            print("Failed to clear notification cache")
        end
        
        print("Clear all process completed")
    end)
    
    dialog.show()
end

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

function notification_list:toggle_dnd()
    local wp = self._private
    wp.dnd_mode = not wp.dnd_mode
    if wp.dnd_mode then
        naughty.suspend()
    else
        naughty.resume()
    end
end

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
                                margins = { right = dpi(11), left = dpi(11) },
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
                                margins = { right = dpi(11), left = dpi(11) },
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
                layout = wibox.layout.overflow.vertical,
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
                font = beautiful.font_name .. dpi(12),
                markup = "No notifications",
            },
        })
    )

    -- Load cached notifications after a brief delay to avoid initialization issues
    local gtimer = require("gears.timer")
    gtimer.delayed_call(function()
        local cached_notifications = notifications_service:get_cached_notifications()
        if cached_notifications and #cached_notifications > 0 then
            -- Remove the "No notifications" placeholder
            notifs_layout:reset()
            -- Add cached notifications (newest first since cache is already in that order)
            for _, cached_notif in ipairs(cached_notifications) do
                -- Create notification widget from cached data
                local cached_widget = create_notification_widget(cached_notif, ret, cached_notif.id)
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
