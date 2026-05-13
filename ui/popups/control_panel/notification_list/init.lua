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
local exit_icon = icons_dir .. "close.svg"

local notification_list = {}

-- Move remove_notification function to top so it's available when referenced
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
                        font = beautiful.font_name .. dpi(12),
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

local function create_notification_widget(
    n,
    notification_list_widget,
    notification_id
)
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
                                        -- Remove this specific notification from the center and cache safely
                                        local success, err = pcall(function()
                                            if notification_id then
                                                local cache = require(
                                                    "ui.notification.cache"
                                                )
                                                cache.remove(notification_id)
                                            end
                                            remove_notification_by_id(
                                                notification_list_widget,
                                                notification_id
                                            )
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

local function add_notification(self, n)
    if not n then
        return
    end
    local notifs_layout = self:get_children_by_id("notifications-layout")[1]

    -- Generate ID if it doesn't exist
    local notification_id = n.id
        or tostring(os.time() .. math.random(1000, 9999))

    local new_notification_widget =
        create_notification_widget(n, self, notification_id)
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
        bg = "#00000033",
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
        hide_dialog()
    end

    local function handle_clear_all()
        hide_dialog()
        if callback then
            callback()
        else
            print("ERROR: No callback function provided")
        end
    end

    -- Create confirm button (left side)
    local confirm_icon = gcolor.recolor_image(trash_icon, beautiful.red)
    local confirm_icon_hover = gcolor.recolor_image(trash_icon, "#000000")
    local confirm_button = wibox.widget({
        widget = wibox.container.background,
        bg = "transparent",
        border_width = dpi(1),
        border_color = beautiful.red,
        shape = shapes.rrect(8),
        buttons = {
            awful.button({}, 1, handle_clear_all),
        },
        {
            widget = wibox.container.margin,
            margins = {
                left = dpi(28),
                right = dpi(8),
                top = dpi(12),
                bottom = dpi(12),
            },
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(3),
                {
                    id = "confirm-icon",
                    widget = wibox.widget.imagebox,
                    image = confirm_icon,
                    resize = true,
                    forced_width = dpi(24),
                    forced_height = dpi(24),
                },
                {
                    id = "confirm-label",
                    widget = wibox.widget.textbox,
                    align = "center",
                    markup = create_markup("Confirm", { fg = beautiful.red }),
                    font = beautiful.font_name .. " " .. dpi(12),
                },
            },
        },
    })
    confirm_button:connect_signal("mouse::enter", function(w)
        w.bg = "linear:0,0:0,32:0,#fc618dcc:1,#b61442cc"
        w.border_color = "transparent"
        local icon = w:get_children_by_id("confirm-icon")[1]
        if icon then icon.image = confirm_icon_hover end
        local label = w:get_children_by_id("confirm-label")[1]
        if label then label:set_markup(create_markup("Confirm", { fg = "#000000" })) end
    end)
    confirm_button:connect_signal("mouse::leave", function(w)
        w.bg = "transparent"
        w.border_color = beautiful.red
        local icon = w:get_children_by_id("confirm-icon")[1]
        if icon then icon.image = confirm_icon end
        local label = w:get_children_by_id("confirm-label")[1]
        if label then label:set_markup(create_markup("Confirm", { fg = beautiful.red })) end
    end)

    -- Create cancel button (right side)
    local cancel_icon = gcolor.recolor_image(exit_icon, beautiful.fg)
    local cancel_button = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg_alt,
        border_width = dpi(2),
        border_color = beautiful.fg .. "66",
        shape = shapes.rrect(8),
        buttons = {
            awful.button({}, 1, handle_cancel),
        },
        {
            widget = wibox.container.margin,
            margins = {
                left = dpi(36),
                right = dpi(16),
                top = dpi(12),
                bottom = dpi(12),
            },
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(3),
                {
                    widget = wibox.widget.imagebox,
                    image = cancel_icon,
                    resize = true,
                    forced_width = dpi(24),
                    forced_height = dpi(24),
                },
                {
                    widget = wibox.widget.textbox,
                    align = "center",
                    markup = "Cancel",
                    font = beautiful.font_name .. " " .. dpi(12),
                },
            },
        },
    })
    cancel_button:connect_signal("mouse::enter", function(w)
        w.bg = beautiful.bg_urg
    end)
    cancel_button:connect_signal("mouse::leave", function(w)
        w.bg = beautiful.bg_alt
    end)

    -- Don't add button functionality separately since it's already in the widget definition

    local dialog = awful.popup({
        visible = false,
        ontop = true,
        type = "dialog",
        screen = screen,
        bg = "#00000000",
        placement = awful.placement.centered,

        widget = {
            widget = wibox.container.background,
            bg = beautiful.bg .. "33",
            border_width = dpi(2),
            border_color = beautiful.fg_alt,
            shape = shapes.rrect(15),
            {
                widget = wibox.container.margin,
                margins = dpi(10),
                {
                    layout = wibox.layout.fixed.vertical,
                    spacing = dpi(32),
                    -- Title
                    {
                        widget = wibox.widget.textbox,
                        align = "center",
                        markup = create_markup("Clear All Notifications"),
                        font = beautiful.font_name .. " 16",
                    },
                    -- Message
                    {
                        widget = wibox.widget.textbox,
                        align = "center",
                        markup = create_markup(
                            "This will permanently delete all notification history.\nAre you sure you want to continue?"
                        ),
                        font = beautiful.font_name .. " 10",
                    },
                    -- Buttons
                    {
                        layout = wibox.layout.flex.horizontal,
                        spacing = dpi(12),
                        confirm_button,
                        cancel_button,
                    },
                },
            },
        },
    })

    dialog_functions.dialog = dialog

    -- Hide dialog when clicking backdrop
    backdrop.buttons = {
        awful.button({}, 1, hide_dialog),
    }

    return {
        show = function()
            backdrop.visible = true
            dialog.visible = true
        end,
        hide = hide_dialog,
    }
end

function notification_list:clear_notifications()
    -- Create confirmation dialog
    local dialog = create_confirmation_dialog(function()
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
        local cached_notifications =
            notifications_service:get_cached_notifications()
        if cached_notifications and #cached_notifications > 0 then
            -- Remove the "No notifications" placeholder
            notifs_layout:reset()
            -- Add cached notifications (newest first since cache is already in that order)
            for _, cached_notif in ipairs(cached_notifications) do
                -- Create notification widget from cached data
                local cached_widget = create_notification_widget(
                    cached_notif,
                    ret,
                    cached_notif.id
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
