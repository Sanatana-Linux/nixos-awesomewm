-- ui/bar/modules/taglist_and_tasklist_buttons.lua
-- A robust, manually-controlled taglist and tasklist implementation
-- that uses comprehensive signal handling to ensure client icons are always updated.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local client = client
local menu = require("ui.menu").get_default() -- Client menu module
local fancy_taglist = {}

-- Creates a single, fully-functional tag widget.
local function create_single_tag(tag, s)
    -- This layout will hold the icons of the clients on the tag.
    local clients_layout = wibox.layout.fixed.horizontal()
    clients_layout.spacing = dpi(6)

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
                    awful.button({}, 3, function()
                        -- Right click: show the client menu.
                        menu:toggle_client_menu(c)
                    end)
                )

                -- Create the client icon and apply the buttons
                local icon = awful.widget.clienticon(c, {
                    forced_height = dpi(14),
                    forced_width = dpi(14),
                })
                icon:buttons(client_buttons)

                -- Add the icon to the layout
                clients_layout:add(icon)
            end
        end
    end

    -- This layout holds the tag name and the client icons.
    local content_layout = wibox.layout.fixed.horizontal()
    content_layout.spacing = dpi(8)
    local tag_label = wibox.widget({
        markup = tostring(tag.name),
        widget = wibox.widget.textbox,
        font = beautiful.taglist_font,
        bg = beautiful.bg_gradient_button,
    })
    content_layout:add(tag_label)
    content_layout:add(clients_layout)

    -- The main container for the tag, handling background and borders.
    local container = wibox.widget({
        {
            content_layout,
            top = dpi(4),
            bottom = dpi(4),
            left = dpi(16),
            right = dpi(16),
            widget = wibox.container.margin,
        },
        shape = beautiful.rrect(beautiful.border_radius or dpi(8)),
        border_width = beautiful.border_width or dpi(1),
        border_color = beautiful.border_color_active,
        widget = wibox.container.background,
        bg = beautiful.bg_gradient_button,
    })

    -- This function updates the tag's appearance based on its state.
    local function update_tag_status()
        if tag.selected then
            container.bg = beautiful.bg_gradient_button_alt
            container.border_color = beautiful.border_color_active
                or beautiful.fg_alt
        else
            container.bg = beautiful.bg_gradient_button
            container.border_color = beautiful.border_color_normal
                or beautiful.bg_urg
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
    container:connect_signal("mouse::enter", function(c)
        c:set_bg(beautiful.bg_gradient_button_alt)
    end)
    container:connect_signal("mouse::leave", function(c)
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

    return taglist_layout
end

return fancy_taglist
