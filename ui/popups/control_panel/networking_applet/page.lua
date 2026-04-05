--[[
Network Management Page

Provides a full management interface for network, allowing users to:
- View all network interfaces (WiFi and Ethernet)
- See connection status for each interface
- View available WiFi access points per wireless interface
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

local ICONS_PATH = gfs.get_configuration_dir()
    .. "ui/popups/control_panel/networking_applet/icons/"
local ICON_WIFI = ICONS_PATH .. "wifi.svg"
local ICON_SEARCH = ICONS_PATH .. "search.svg"
local ICON_BACK = ICONS_PATH .. "arrow-left.svg"
local ICON_CHECK = ICONS_PATH .. "check.svg"
local ICON_REFRESH = ICONS_PATH .. "refresh.svg"
local ICON_ETHERNET = ICONS_PATH .. "ethernet.svg"

local WHITE = applet_pages.WHITE

local network_page = {}

local function create_interface_header(dev, is_wireless)
    local interface_name = dev:get_interface() or "Unknown"
    local state = dev:get_state()
    local state_str = network.device_state_to_string(state) or "Unknown"
    local ip_addr = dev:get_ip4_address()
    local dev_type = dev:get_type_string()

    local icon = is_wireless and ICON_WIFI or ICON_ETHERNET
    local status_text

    if state == network.DeviceState.ACTIVATED then
        status_text = ip_addr and string.format("Connected  %s", ip_addr)
            or "Connected"
    else
        status_text = state_str
    end

    return wibox.widget({
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(4),
        {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(8),
            {
                widget = wibox.widget.imagebox,
                image = gcolor.recolor_image(icon, WHITE),
                forced_height = dpi(16),
                forced_width = dpi(16),
                resize = true,
            },
            {
                widget = wibox.widget.textbox,
                markup = string.format(
                    "<span foreground='%s' font_weight='bold'>%s</span>",
                    WHITE,
                    interface_name
                ),
            },
            {
                widget = wibox.widget.textbox,
                markup = string.format(
                    "<span foreground='%s' font_size='small'>(%s)</span>",
                    beautiful.fg_alt,
                    dev_type
                ),
            },
        },
        {
            widget = wibox.container.margin,
            margins = { left = dpi(24) },
            {
                widget = wibox.widget.textbox,
                markup = string.format(
                    "<span foreground='%s' font_size='small'>%s</span>",
                    state == network.DeviceState.ACTIVATED and beautiful.fg
                        or beautiful.fg_alt,
                    status_text
                ),
            },
        },
    })
end

local function create_ap_widget(self, dev, ap)
    local ap_ssid = ap:get_ssid()
    local ap_strength = ap:get_strength()
    local active_ap = dev:get_active_access_point()
    local ap_is_active = ap == active_ap

    local ap_widget = wibox.widget(applet_pages.create_item_widget({
        name = ap_ssid or "Unknown",
        check_icon = gcolor.recolor_image(ICON_CHECK, WHITE),
        is_active = ap_is_active,
        status_markup = string.format(
            "<span foreground='%s'>%s</span>",
            WHITE,
            ap_strength > 70 and "▂▄▆█"
                or ap_strength > 45 and "▂▄▆"
                or ap_strength > 20 and "▂▄"
                or "▂"
        ),
    }))

    ap_widget.active = ap_is_active
    ap_widget.dev = dev
    ap_widget.ap = ap

    applet_pages.setup_item_effects(ap_widget)

    ap_widget:buttons({
        awful.button({}, 1, function()
            self:open_ap_menu(dev, ap)
        end),
    })

    return ap_widget
end

local function refresh_interface_list(self)
    local wp = self._private
    local content_layout = self:get_children_by_id("content-layout")[1]

    wp.interface_widgets = {}
    wp.ap_widgets = {}

    if not client:get_wireless_enabled() then
        content_layout:reset()
        content_layout:add(applet_pages.create_empty_state({
            text = "Wifi Disabled",
        }))
        return
    end

    content_layout:reset()

    for _, dev in ipairs(client.devices) do
        local is_wireless = dev:get_type() == network.DeviceType.WIFI
        local header = create_interface_header(dev, is_wireless)
        table.insert(wp.interface_widgets, header)
        content_layout:add(wibox.widget({
            widget = wibox.container.margin,
            margins = {
                top = dpi(6),
                bottom = dpi(4),
                left = dpi(12),
                right = dpi(12),
            },
            header,
        }))

        if is_wireless and dev._private.wireless_proxy then
            local aps = dev:get_access_points()
            if aps then
                local has_aps = false
                for _ in pairs(aps) do
                    has_aps = true
                    break
                end

                if has_aps then
                    for _, ap in pairs(aps) do
                        if ap:get_ssid() ~= nil then
                            local ap_widget = create_ap_widget(self, dev, ap)
                            if ap_widget.active then
                                content_layout:insert(
                                    #content_layout.children,
                                    ap_widget
                                )
                            else
                                content_layout:add(ap_widget)
                            end
                            table.insert(wp.ap_widgets, ap_widget)
                        end
                    end
                else
                    local state = dev:get_state()
                    if state ~= network.DeviceState.ACTIVATED then
                        content_layout:add(wibox.widget({
                            widget = wibox.container.margin,
                            margins = { left = dpi(24), bottom = dpi(8) },
                            {
                                widget = wibox.widget.textbox,
                                markup = string.format(
                                    "<span foreground='%s' font_size='small'>No networks found</span>",
                                    beautiful.fg_alt
                                ),
                            },
                        }))
                    end
                end
            end
        end
    end

    if #client.devices == 0 then
        content_layout:add(
            applet_pages.create_empty_state({ icon = ICON_SEARCH })
        )
    end
end

local function on_wireless_enabled(self, enabled)
    local wp = self._private
    local content_layout = self:get_children_by_id("content-layout")[1]
    local bottombar_toggle_icon =
        self:get_children_by_id("bottombar-toggle-icon")[1]

    bottombar_toggle_icon:set_image(gcolor.recolor_image(ICON_WIFI, WHITE))

    if enabled then
        refresh_interface_list(self)
    else
        wp.interface_widgets = {}
        wp.ap_widgets = {}
        content_layout:reset()
        content_layout:add(applet_pages.create_empty_state({
            text = "Wifi Disabled",
        }))
        if wp.ap_menu then
            wp.ap_menu:get_children_by_id("password-input")[1]:unfocus()
        end
    end
end

function network_page:open_ap_menu(dev, ap)
    local wp = self._private
    local content_layout = self:get_children_by_id("content-layout")[1]

    local active_ap = dev:get_active_access_point()
    local is_connected = ap == active_ap

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

    local interface_label = wp.ap_menu:get_children_by_id("interface-label")[1]
    if interface_label then
        interface_label:set_markup(
            string.format(
                "<span foreground='%s'>Interface: %s</span>",
                beautiful.fg_alt,
                dev:get_interface()
            )
        )
    end

    local password_widget = wp.ap_menu:get_children_by_id("password-widget")[1]
    local password_input = wp.ap_menu:get_children_by_id("password-input")[1]
    local connect_disconnect_button =
        wp.ap_menu:get_children_by_id("connect-disconnect-button")[1]

    if not is_connected then
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
        connect_disconnect_button:set_label("Disconnect")
        connect_disconnect_button:buttons({
            awful.button({}, 1, function()
                client:disconnect_access_point(dev)
                self:close_ap_menu()
                dev:request_scan()
            end),
        })
        password_widget.visible = false
    end

    content_layout:reset()
    content_layout:add(wp.ap_menu)
end

function network_page:close_ap_menu()
    local wp = self._private
    local content_layout = self:get_children_by_id("content-layout")[1]
    local password_input = wp.ap_menu:get_children_by_id("password-input")[1]

    if client:get_wireless_enabled() then
        password_input:unfocus()
        password_input:set_obscure(true)
        refresh_interface_list(self)
    end
end

function network_page:refresh()
    refresh_interface_list(self)
    for _, dev in ipairs(client.wireless_devices) do
        if dev.request_scan then
            dev:request_scan()
        end
    end
end

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

    gtable.crush(ret, network_page, true)
    local wp = ret._private
    wp.interface_widgets = {}
    wp.ap_widgets = {}

    wp.ap_menu = wibox.widget({
        layout = wibox.layout.fixed.vertical,
        forced_height = dpi(450),
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
            widget = wibox.container.margin,
            margins = { left = dpi(15), right = dpi(15), bottom = dpi(5) },
            {
                id = "interface-label",
                widget = wibox.widget.textbox,
                markup = "",
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
            applet_pages.create_action_button({
                id = "connect-disconnect-button",
                label_id = "connect-disconnect-label",
            }),
        },
    })

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

    for _, dev in ipairs(client.wireless_devices) do
        dev:connect_signal("property::access-points", function()
            refresh_interface_list(ret)
        end)

        dev:connect_signal("property::state", function(_, state)
            if
                state == network.DeviceState.ACTIVATED
                or state == network.DeviceState.DISCONNECTED
            then
                refresh_interface_list(ret)
            end
        end)
    end

    client:connect_signal("property::wireless-enabled", function(_, enabled)
        on_wireless_enabled(ret, enabled)
    end)

    on_wireless_enabled(ret, client:get_wireless_enabled())

    return ret
end

return setmetatable({
    new = new,
}, { __call = new })
