--[[
WiFi Management Page

Provides a full management interface for WiFi, allowing users to:
- View a list of available access points
- Connect to or disconnect from access points
- Enable/disable WiFi functionality
- Refresh the access point list
--]]

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gcolor = require("gears.color")
local gfs = require("gears.filesystem")
local gtable = require("gears.table")
local modules = require("modules")
local dpi = beautiful.xresources.apply_dpi
local network = require("service.network")
local shapes = require("modules.shapes.init")
local applet_pages = require("modules.applet_pages")

local client = network.get_default()

------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------

local ICONS_PATH = gfs.get_configuration_dir()
    .. "ui/popups/control_panel/wifi_applet/icons/"
local ICON_WIFI = ICONS_PATH .. "wifi.svg"
local ICON_SEARCH = ICONS_PATH .. "search.svg"
local ICON_BACK = ICONS_PATH .. "arrow-left.svg"
local ICON_CHECK = ICONS_PATH .. "check.svg"
local ICON_REFRESH = ICONS_PATH .. "refresh.svg"

local WHITE = applet_pages.WHITE

local wifi_page = {}

------------------------------------------------------------------------
-- Helper Functions
------------------------------------------------------------------------

-- Creates a widget representing an access point in the list
local function create_ap_widget(self, ap)
    local ap_ssid = ap:get_ssid()
    local ap_strength = ap:get_strength()
    local ap_is_active = ap == client.wireless:get_active_access_point()

    local ap_widget = wibox.widget({
        active = ap_is_active,
        widget = wibox.container.background,
        shape = shapes.rrect(10),
        border_width = dpi(1),
        border_color = WHITE,
        {
            widget = wibox.container.margin,
            forced_height = dpi(50),
            margins = dpi(15),
            {
                layout = wibox.layout.align.horizontal,
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(8),
                    {
                        id = "check-icon",
                        widget = wibox.widget.imagebox,
                        image = gcolor.recolor_image(ICON_CHECK, WHITE),
                        forced_height = dpi(14),
                        forced_width = dpi(14),
                        resize = true,
                        visible = ap_is_active,
                    },
                    {
                        widget = wibox.container.constraint,
                        width = dpi(250),
                        {
                            id = "name",
                            widget = wibox.widget.textbox,
                        },
                    },
                },
                nil,
                {
                    id = "strength",
                    widget = wibox.widget.textbox,
                },
            },
        },
    })

    -- Populate SSID and signal strength
    local name = ap_widget:get_children_by_id("name")[1]
    name:set_markup(
        string.format(
            "<span foreground='%s'>%s</span>",
            WHITE,
            ap_ssid or "Unknown"
        )
    )

    local strength = ap_widget:get_children_by_id("strength")[1]
    strength:set_markup(
        string.format(
            "<span foreground='%s'>%s</span>",
            WHITE,
            ap_strength > 70 and "▂▄▆█"
                or ap_strength > 45 and "▂▄▆"
                or ap_strength > 20 and "▂▄"
                or "▂"
        )
    )

    -- Hover effect
    ap_widget:connect_signal("mouse::enter", function(w)
        w:set_bg(beautiful.bg_urg)
    end)
    ap_widget:connect_signal("mouse::leave", function(w)
        w:set_bg(nil)
    end)

    -- Click to open connection menu
    ap_widget:buttons({
        awful.button({}, 1, function()
            self:open_ap_menu(ap)
        end),
    })

    return ap_widget
end

-- Updates the list of access points
local function on_ap_list_changed(self)
    local wp = self._private
    local content_layout = self:get_children_by_id("content-layout")[1]
    wp.ap_widgets = {}

    for _, ap in pairs(client.wireless:get_access_points()) do
        if ap:get_ssid() ~= nil then
            local ap_widget = create_ap_widget(self, ap)
            table.insert(wp.ap_widgets, ap_widget)
        end
    end

    -- Refresh layout if not currently in a menu
    if content_layout.children[1] ~= wp.ap_menu and #wp.ap_widgets ~= 0 then
        content_layout:reset()
        for _, ap_widget in ipairs(wp.ap_widgets) do
            if ap_widget.active then
                content_layout:insert(1, ap_widget)
            else
                content_layout:add(ap_widget)
            end
        end
    end
end

-- Handles UI updates when WiFi is enabled/disabled
local function on_wireless_enabled(self, enabled)
    local wp = self._private
    local content_layout = self:get_children_by_id("content-layout")[1]
    local bottombar_toggle_icon =
        self:get_children_by_id("bottombar-toggle-icon")[1]

    if enabled then
        bottombar_toggle_icon:set_image(gcolor.recolor_image(ICON_WIFI, WHITE))
        content_layout:reset()
        content_layout:add(wibox.widget({
            widget = wibox.container.place,
            forced_height = dpi(400),
            halign = "center",
            valign = "center",
            {
                widget = wibox.widget.imagebox,
                image = gcolor.recolor_image(ICON_SEARCH, WHITE),
                forced_height = dpi(25),
                forced_width = dpi(25),
                resize = true,
            },
        }))
    else
        wp.ap_widgets = {}
        bottombar_toggle_icon:set_image(gcolor.recolor_image(ICON_WIFI, WHITE))
        content_layout:reset()
        content_layout:add(wibox.widget({
            widget = wibox.container.place,
            forced_height = dpi(400),
            halign = "center",
            valign = "center",
            {
                widget = wibox.widget.textbox,
                align = "center",
                font = beautiful.font_name .. dpi(12),
                markup = "<span foreground='"
                    .. WHITE
                    .. "'>Wifi Disabled</span>",
            },
        }))
        -- Clean up menu if open
        wp.ap_menu:get_children_by_id("password-input")[1]:unfocus()
    end
end

------------------------------------------------------------------------
-- Public Methods
------------------------------------------------------------------------

-- Opens the connection menu for a specific access point
function wifi_page:open_ap_menu(ap)
    local wp = self._private
    local content_layout = self:get_children_by_id("content-layout")[1]

    local obscure = true
    local auto_connect = true

    local close_button = wp.ap_menu:get_children_by_id("close-button")[1]
    close_button:buttons({
        awful.button({}, 1, function()
            self:close_ap_menu()
        end),
    })

    local title = wp.ap_menu:get_children_by_id("title")[1]
    title:set_markup(
        string.format("<span foreground='%s'>%s</span>", WHITE, ap:get_ssid())
    )

    local password_widget = wp.ap_menu:get_children_by_id("password-widget")[1]
    local password_input = wp.ap_menu:get_children_by_id("password-input")[1]
    local connect_disconnect_button =
        wp.ap_menu:get_children_by_id("connect-disconnect-button")[1]

    -- Menu for un-connected AP (Password input required)
    if ap ~= client.wireless:get_active_access_point() then
        -- Obscure/Unobscure password toggle
        local obscure_icon = wp.ap_menu:get_children_by_id("obscure-icon")[1]
        obscure_icon:set_image(
            gcolor.recolor_image(ICONS_PATH .. "eye-off.svg", WHITE)
        )
        obscure_icon:buttons({
            awful.button({}, 1, function()
                obscure = not obscure
                password_input:set_obscure(obscure)
                if obscure then
                    obscure_icon:set_image(
                        gcolor.recolor_image(ICONS_PATH .. "eye-off.svg", WHITE)
                    )
                else
                    obscure_icon:set_image(
                        gcolor.recolor_image(ICONS_PATH .. "eye.svg", WHITE)
                    )
                end
            end),
        })

        -- Auto-connect toggle
        local auto_connect_icon =
            wp.ap_menu:get_children_by_id("auto-connect-icon")[1]
        auto_connect_icon:set_image(gcolor.recolor_image(ICON_CHECK, WHITE))
        auto_connect_icon:buttons({
            awful.button({}, 1, function()
                auto_connect = not auto_connect
                if auto_connect then
                    auto_connect_icon:set_image(
                        gcolor.recolor_image(ICON_CHECK, WHITE)
                    )
                else
                    auto_connect_icon:set_image(
                        gcolor.recolor_image(
                            ICONS_PATH .. "check-off.svg",
                            WHITE
                        )
                    )
                end
            end),
        })

        connect_disconnect_button:set_label("Connect")
        connect_disconnect_button:buttons({
            awful.button({}, 1, function()
                client:connect_access_point(
                    ap,
                    password_input:get_input(),
                    auto_connect
                )
                self:close_ap_menu()
            end),
        })

        password_input:on_focused(function()
            password_input:set_input("")
            password_input:set_cursor_index(1)
        end)

        password_input:on_unfocused(function()
            self:close_ap_menu()
        end)

        password_input:on_executed(function(_, input)
            client:connect_access_point(ap, input, auto_connect)
            self:close_ap_menu()
        end)

        password_widget.visible = true
        password_input:focus()
    else
        -- Menu for connected AP (Disconnect only)
        connect_disconnect_button:set_label("Disconnect")
        connect_disconnect_button:buttons({
            awful.button({}, 1, function()
                client:disconnect_active_access_point()
                self:close_ap_menu()
                client.wireless:request_scan()
            end),
        })
        password_widget.visible = false
    end

    content_layout:reset()
    content_layout:add(wp.ap_menu)
end

function wifi_page:close_ap_menu()
    local wp = self._private
    local content_layout = self:get_children_by_id("content-layout")[1]
    local password_input = wp.ap_menu:get_children_by_id("password-input")[1]

    if client:get_wireless_enabled() then
        password_input:unfocus()
        password_input:set_obscure(true)
        content_layout:reset()
        for _, ap_widget in ipairs(wp.ap_widgets) do
            if ap_widget.active then
                content_layout:insert(1, ap_widget)
            else
                content_layout:add(ap_widget)
            end
        end
    end
end

function wifi_page:refresh()
    on_ap_list_changed(self)
    client.wireless:request_scan()
end

------------------------------------------------------------------------
-- Widget Factory
------------------------------------------------------------------------

local function new()
    local ret = applet_pages.create_base_page({
        left_buttons = {
            applet_pages.create_button({
                id = "bottombar-toggle-button",
                icon_id = "bottombar-toggle-icon",
                icon = gcolor.recolor_image(ICON_WIFI, WHITE),
            }),
            applet_pages.create_button({
                id = "bottombar-refresh-button",
                icon_id = "bottombar-refresh-icon",
                icon = gcolor.recolor_image(ICON_REFRESH, WHITE),
            }),
        },
        right_buttons = {
            applet_pages.create_button({
                id = "bottombar-close-button",
                icon_id = "bottombar-close-icon",
                icon = gcolor.recolor_image(ICON_BACK, WHITE),
            }),
        },
    })

    gtable.crush(ret, wifi_page, true)
    local wp = ret._private
    wp.ap_widgets = {}

    -- AP Connection Menu
    wp.ap_menu = wibox.widget({
        layout = wibox.layout.fixed.vertical,
        forced_height = dpi(400),
        {
            widget = wibox.container.margin,
            margins = dpi(15),
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(15),
                {
                    id = "close-button",
                    widget = wibox.widget.imagebox,
                    image = gcolor.recolor_image(ICON_BACK, WHITE),
                    forced_height = dpi(18),
                    forced_width = dpi(18),
                    resize = true,
                },
                {
                    id = "title",
                    widget = wibox.widget.textbox,
                },
            },
        },
        {
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(15),
            {
                id = "password-widget",
                widget = wibox.container.background,
                bg = beautiful.bg_alt,
                shape = shapes.rrect(10),
                border_width = dpi(1),
                border_color = WHITE,
                {
                    widget = wibox.container.margin,
                    margins = dpi(15),
                    {
                        layout = wibox.layout.fixed.vertical,
                        spacing = dpi(10),
                        -- Password Input
                        {
                            widget = wibox.container.margin,
                            margins = { left = dpi(10), right = dpi(10) },
                            {
                                layout = wibox.layout.align.horizontal,
                                {
                                    widget = wibox.container.constraint,
                                    forced_width = dpi(310),
                                    strategy = "max",
                                    height = dpi(25),
                                    {
                                        id = "password-input",
                                        widget = modules.text_input({
                                            placeholder = "Password",
                                            cursor_bg = WHITE,
                                            cursor_fg = beautiful.bg,
                                            placeholder_fg = beautiful.fg_alt,
                                            obscure = true,
                                        }),
                                    },
                                },
                                nil,
                                {
                                    id = "obscure-icon",
                                    widget = wibox.widget.imagebox,
                                    forced_height = dpi(18),
                                    forced_width = dpi(18),
                                    resize = true,
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
                                color = WHITE,
                            },
                        },
                        -- Auto Connect Toggle
                        {
                            widget = wibox.container.margin,
                            margins = { left = dpi(10), right = dpi(10) },
                            {
                                layout = wibox.layout.align.horizontal,
                                {
                                    widget = wibox.widget.textbox,
                                    markup = string.format(
                                        "<span foreground='%s'>Auto connect</span>",
                                        WHITE
                                    ),
                                },
                                nil,
                                {
                                    id = "auto-connect-icon",
                                    widget = wibox.widget.imagebox,
                                    forced_height = dpi(18),
                                    forced_width = dpi(18),
                                    resize = true,
                                },
                            },
                        },
                    },
                },
            },
            {
                id = "connect-disconnect-button",
                widget = wibox.container.background,
                shape = shapes.rrect(10),
                border_width = dpi(1),
                border_color = WHITE,
                bg = beautiful.bg_gradient_button,
                {
                    widget = wibox.container.margin,
                    margins = dpi(10),
                    {
                        id = "connect-disconnect-label",
                        widget = wibox.widget.textbox,
                        align = "center",
                    },
                },
            },
        },
    })

    --------------------------------------------------------------------
    -- Interaction/Signal Connections
    --------------------------------------------------------------------

    -- Button hover/click effects
    local bottombar_toggle_button =
        ret:get_children_by_id("bottombar-toggle-button")[1]
    applet_pages.setup_button_effects(bottombar_toggle_button)
    bottombar_toggle_button:buttons({
        awful.button({}, 1, function()
            client:set_wireless_enabled(not client:get_wireless_enabled())
        end),
    })

    local bottombar_refresh_button =
        ret:get_children_by_id("bottombar-refresh-button")[1]
    applet_pages.setup_button_effects(bottombar_refresh_button)
    bottombar_refresh_button:buttons({
        awful.button({}, 1, function()
            if client:get_wireless_enabled() then
                ret:refresh()
            end
        end),
    })

    local bottombar_close_button =
        ret:get_children_by_id("bottombar-close-button")[1]
    applet_pages.setup_button_effects(bottombar_close_button)

    local connect_disconnect_button =
        wp.ap_menu:get_children_by_id("connect-disconnect-button")[1]
    applet_pages.setup_button_effects(connect_disconnect_button)

    function connect_disconnect_button:set_label(label)
        local lbl = self:get_children_by_id("connect-disconnect-label")[1]
        lbl:set_markup(
            string.format("<span foreground='%s'>%s</span>", WHITE, label)
        )
    end

    -- Service Signals
    client.wireless:connect_signal("property::access-points", function()
        on_ap_list_changed(ret)
    end)

    client.wireless:connect_signal("property::state", function(_, state)
        if
            state == network.DeviceState.ACTIVATED
            or state == network.DeviceState.DISCONNECTED
        then
            on_ap_list_changed(ret)
        end
    end)

    client:connect_signal("property::wireless-enabled", function(_, enabled)
        on_wireless_enabled(ret, enabled)
    end)

    -- Initial load
    on_wireless_enabled(ret, client:get_wireless_enabled())

    if
        client.wireless:get_state() == network.DeviceState.ACTIVATED
        or client.wireless:get_state() == network.DeviceState.DISCONNECTED
    then
        on_ap_list_changed(ret)
    end

    return ret
end

return setmetatable({
    new = new,
}, { __call = new })
