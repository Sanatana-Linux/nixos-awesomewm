-- ui/bar/modules/taglist_and_tasklist_buttons.lua
-- A robust, manually-controlled taglist and tasklist implementation
-- that uses comprehensive signal handling to ensure client icons are always updated.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local menu = require("ui.popups.menu").get_default()
local gears = require("gears") -- Required for filesystem checks
local naughty = require("naughty") -- Required for notifications
local fancy_taglist = {}
local shapes = require("modules.shapes")

-- Creates a single, fully-functional tag widget.
local function create_single_tag(tag, s)
    -- This layout will hold the icons of the clients on the tag.
    local clients_layout = wibox.layout.fixed.horizontal()
    clients_layout.spacing = dpi(4)

    -- This function clears and repopulates the client icon list for this tag.
    local function update_clients()
        clients_layout:reset()

        local cls = tag:clients()
        if #cls > 0 then
            for _, c in ipairs(cls) do
                -- Define buttons for the client icon (tasklist item)
                local client_buttons = awful.util.table.join(
                    awful.button({}, 1, function()
                        -- Left click: jump to the client, focusing it and its tag.
                        awful.client.jumpto(c)
                    end),
                    awful.button({}, 2, function()
                        -- Middle click: minimize the client.
                        c.minimized = true
                    end),
                    awful.button({}, 3, function()
                        -- Right click: show the client menu.
                        menu:toggle_client_menu(c)
                    end)
                )

                -- Create the client icon or a fallback if no icon is available
                local icon_widget
                if c.icon then
                    icon_widget = awful.widget.clienticon(c, {
                        forced_height = dpi(18),
                        forced_width = dpi(18),
                    })
                else
                    -- Use a fallback icon for clients without a specific icon
                    icon_widget = wibox.widget.imagebox()
                    icon_widget.image =
                        "/home/tlh/.config/awesome/themes/yerba_buena/icons/desktop/fallback_icon.svg"
                    icon_widget.forced_height = dpi(18)
                    icon_widget.forced_width = dpi(18)
                end
                icon_widget:buttons(client_buttons)

                -- Add the icon to the layout
                clients_layout:add(icon_widget)
            end
        end
    end

    -- This layout holds the tag name and the client icons.
    local content_layout = wibox.layout.fixed.horizontal()
    content_layout.spacing = dpi(8)
    local tag_label = wibox.widget.imagebox()
    local tag_icon_path = string.format(
        "/home/tlh/.config/awesome/themes/yerba_buena/icons/tags/%s.svg",
        string.lower(tag.name)
    )
    local fallback_icon_path =
        "/home/tlh/.config/awesome/themes/yerba_buena/icons/fallback_icon.svg"

    -- Check if the specific tag icon exists, otherwise use a fallback
    if gears.filesystem.file_readable(tag_icon_path) then
        tag_label.image = tag_icon_path
    else
        tag_label.image = fallback_icon_path
    end
    tag_label.forced_height = dpi(18) -- Adjust size as needed
    tag_label.forced_width = dpi(18) -- Adjust size as needed

    -- Create a fixed-size container for the tag label to prevent resizing
    local tag_label_container = wibox.widget({
        {
            tag_label,
            widget = wibox.container.place,
            halign = "center",
            valign = "center",
        },
        width = dpi(26), -- Fixed width for the icon area
        height = dpi(26), -- Fixed height for the icon area
        widget = wibox.container.constraint,
    })

    content_layout:add(tag_label_container)
    if clients_layout == nil then
        content_layout.forced_width = 0
    else
        content_layout:add(clients_layout)
    end
    -- The inner container for the tag, handling background and borders.
    local inner_container = wibox.widget({
        {
            content_layout,
            top = dpi(2), -- Adjusted margin for height
            bottom = dpi(2), -- Adjusted margin for height
            left = dpi(12),
            right = dpi(12),
            widget = wibox.container.margin,
        },
        shape = shapes.rrect(beautiful.border_radius or dpi(8)),
        border_width = dpi(0),
        border_color = beautiful.border_color_active,
        widget = wibox.container.background,

        bg = beautiful.bg_gradient_button,
    })

    -- Outer margin and background for transparent border effect
    local container = wibox.widget({
        {
            inner_container,
            top = dpi(1),
            bottom = dpi(1),
            left = dpi(1),
            right = dpi(1),
            widget = wibox.container.margin,
        },
        shape = shapes.rrect(beautiful.border_radius or dpi(8)),
        border_width = dpi(1),
        border_color = "transparent",
        widget = wibox.container.background,
        bg = beautiful.bg_gradient_button,
    })

    -- This function updates the tag's appearance based on its state.
    local function update_tag_status()
        if tag.selected then
            inner_container.bg = beautiful.bg_gradient_button_alt
            inner_container.border_color = beautiful.border_color_active
                or beautiful.fg_alt
            container.bg = beautiful.bg_gradient_button_alt
            container.border_color = beautiful.fg .. "66"
        else
            inner_container.bg = beautiful.bg_gradient_button
            inner_container.border_color = beautiful.border_color_normal
                or beautiful.bg_urg
            container.bg = beautiful.bg_gradient_button
            container.border_color = "transparent"
        end
    end

    -- Set initial state and connect signals for state changes.
    update_tag_status()
    tag:connect_signal("property::selected", update_tag_status)
    tag:connect_signal("property::selected", update_clients)

    -- Robustly connect to global signals to ensure icons are always updated.
    client.connect_signal("manage", update_clients)
    client.connect_signal("unmanage", update_clients)
    client.connect_signal("tagged", function(_, t)
        if t == tag then
            update_clients()
        end
    end)
    client.connect_signal("untagged", function(_, t)
        if t == tag then
            update_clients()
        end
    end)
    -- Also update on focus change in case the icon needs to reflect state
    client.connect_signal("focus", update_clients)
    client.connect_signal("unfocus", update_clients)

    -- Connect hover signals for visual feedback.
    container:connect_signal("mouse::enter", function()
        inner_container.bg = beautiful.bg_gradient_recessed
        container.bg = beautiful.bg_gradient_recessed
    end)
    container:connect_signal("mouse::leave", function()
        update_tag_status() -- Revert to selected/unselected state
    end)

    -- Add the button to switch to the tag on click (on the tag label/background).
    container:buttons(awful.button({}, 1, function()
        tag:view_only()
    end))

    -- Initial population of clients
    update_clients()

    return container
end

-- The main exported function that creates the entire taglist widget.
function fancy_taglist.new(cfg)
    cfg = cfg or {}
    local s = cfg.screen or awful.screen.focused()

    -- The main layout that will hold all individual tag widgets.
    local taglist_layout = wibox.layout.fixed.horizontal()
    taglist_layout.spacing = dpi(8)

    -- Create and add a widget for each tag on the screen.
    for _, t in ipairs(s.tags) do
        taglist_layout:add(create_single_tag(t, s))
    end

    -- Wrap the taglist in a background container for the gradient
    local bar_container = wibox.widget({
        taglist_layout,
        widget = wibox.container.place,
        fill_vertical = true, -- This ensures the taglist expands vertically
        halign = "center",
        valign = "center",

        bg = "#00000000",
    })

    return bar_container
end

return fancy_taglist
