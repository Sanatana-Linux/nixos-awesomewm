--[[
Networking applet state management.

Refresh logic, AP connection flow, wireless toggle handler, and AP menu
open/close. These functions take the page instance (self) as first argument
and operate on its _private state. They are attached to the page object
via gtable.crush in page.lua.
--]]

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gcolor = require("gears.color")
local shapes = require("modules.style.shapes.init")
local dpi = beautiful.xresources.apply_dpi
local network = require("service.network")
local client = network.get_default()
local applet_pages = require("modules.infra.applet_pages")
local widgets = require("ui.popups.control_panel.networking_applet.widgets")

local M = {}

--- Refresh the interface / AP list from scratch.
-- Builds the content layout from scratch, sorting APs connected-first
-- then by signal strength descending.
-- @tparam table self Page instance
----------------------------------------------------------------------
function M.refresh_interface_list(self)
    local wp = self._private
    local content_layout = self:get_children_by_id("content-layout")[1]

    wp.interface_widgets = {}
    wp.ap_widgets = {}

    -- Check NM availability
    if not client or not client.devices or #client.devices == 0 then
        content_layout:reset()
        content_layout:add(applet_pages.create_empty_state({
            icon = widgets.ICONS_PATH .. "search.svg",
            text = "No NetworkManager\ndevices found",
        }))
        return
    end

    -- WiFi disabled state
    if not client:get_wireless_enabled() then
        content_layout:reset()
        content_layout:add(applet_pages.create_empty_state({
            icon = widgets.ICONS_PATH .. "wifi.svg",
            text = "WiFi Disabled\nEnable WiFi to see available networks",
        }))
        return
    end

    content_layout:reset()

    for i, dev in ipairs(client.devices) do
        local is_wireless = dev:get_type() == network.DeviceType.WIFI
        local state = dev:get_state()

        -- Section divider between interfaces
        if i > 1 then
            local iface_name = dev:get_interface() or "Unknown"
            content_layout:add(wibox.widget({
                widget = wibox.container.margin,
                margins = {
                    top = dpi(4),
                    bottom = dpi(2),
                    left = dpi(4),
                },
                {
                    widget = wibox.widget.textbox,
                    markup = string.format(
                        "<span foreground='%s' font_size='x-small'>── %s ──</span>",
                        beautiful.fg_alt,
                        iface_name
                    ),
                },
            }))
        end

        local header = widgets.create_interface_header(dev, is_wireless)

        table.insert(wp.interface_widgets, header)
        content_layout:add(header)

        -- Wireless AP list
        if is_wireless and dev._private.wireless_proxy then
            local aps = dev:get_access_points()
            if aps then
                -- Collect visible SSIDs
                local ap_list = {}
                for _, ap in pairs(aps) do
                    if ap:get_ssid() ~= nil then
                        table.insert(ap_list, ap)
                    end
                end

                -- Sort: connected first, then by strength descending
                table.sort(ap_list, function(a, b)
                    local a_act = a == dev:get_active_access_point()
                    local b_act = b == dev:get_active_access_point()
                    if a_act ~= b_act then
                        return a_act
                    end
                    return (a:get_strength() or 0) > (b:get_strength() or 0)
                end)

                if #ap_list > 0 then
                    for _, ap in ipairs(ap_list) do
                        local ap_w = widgets.create_ap_widget(
                            dev,
                            ap,
                            function()
                                self:open_ap_menu(dev, ap)
                            end
                        )
                        content_layout:add(ap_w)
                        table.insert(wp.ap_widgets, ap_w)
                    end
                elseif state ~= network.DeviceState.ACTIVATED then
                    -- No APs yet but device is not connected
                    content_layout:add(wibox.widget({
                        widget = wibox.container.margin,
                        margins = {
                            left = dpi(24),
                            bottom = dpi(8),
                        },
                        {
                            widget = wibox.widget.textbox,
                            markup = string.format(
                                "<span foreground='%s' font_size='small'>"
                                    .. "Scanning for networks...</span>",
                                beautiful.fg_alt
                            ),
                        },
                    }))
                end
            end
        end

        -- Ethernet disconnect button (only when connected)
        if not is_wireless and state == network.DeviceState.ACTIVATED then
            local disconnect_btn = wibox.widget({
                widget = wibox.container.background,
                shape = shapes.rrect(6),
                border_width = dpi(1),
                border_color = "transparent",
                bg = beautiful.bg_gradient_button,
                {
                    widget = wibox.container.margin,
                    margins = dpi(8),
                    {
                        widget = wibox.widget.textbox,
                        align = "center",
                        markup = string.format(
                            "<span foreground='%s'>Disconnect</span>",
                            beautiful.red
                        ),
                    },
                },
            })
            disconnect_btn:connect_signal("mouse::enter", function(w)
                w:set_bg(beautiful.bg_gradient_recessed)
                w:set_border_color(beautiful.red .. "66")
            end)
            disconnect_btn:connect_signal("mouse::leave", function(w)
                w:set_bg(beautiful.bg_gradient_button)
                w:set_border_color("transparent")
            end)
            widgets.add_tooltip(
                disconnect_btn,
                "Disconnect "
                    .. (dev:get_interface() or "Ethernet")
                    .. " from the current network"
            )
            disconnect_btn:buttons({
                awful.button({}, 1, function()
                    client:disconnect_access_point(dev)
                end),
            })
            content_layout:add(wibox.widget({
                widget = wibox.container.margin,
                margins = {
                    left = dpi(24),
                    right = dpi(24),
                    bottom = dpi(8),
                },
                disconnect_btn,
            }))
        end
    end
end

--- Wireless enabled/disabled handler.
-- Shows the AP list when enabled, or the disabled placeholder when off.
-- @tparam table self Page instance
-- @tparam boolean enabled Whether WiFi is enabled
----------------------------------------------------------------------
function M.on_wireless_enabled(self, enabled)
    local wp = self._private
    local content_layout = self:get_children_by_id("content-layout")[1]

    if enabled then
        M.refresh_interface_list(self)
    else
        wp.interface_widgets = {}
        wp.ap_widgets = {}
        content_layout:reset()
        content_layout:add(applet_pages.create_empty_state({
            icon = widgets.ICONS_PATH .. "wifi.svg",
            text = "WiFi Disabled\nEnable WiFi to see available networks",
        }))
        -- Clear any open AP menu
        local password_input =
            wp.ap_menu:get_children_by_id("password-input")[1]
        if password_input then
            password_input:unfocus()
        end
        wp.current_ap_dev = nil
        wp.current_ap = nil
    end
end

--- Open the AP connection menu for a specific access point.
-- Switches the content area to show the password / connect (or disconnect)
-- form for the given AP.
-- @tparam table self Page instance
-- @tparam table dev NetworkManager device object
-- @tparam table ap Access-point object
----------------------------------------------------------------------
function M.open_ap_menu(self, dev, ap)
    local wp = self._private
    local content_layout = self:get_children_by_id("content-layout")[1]
    wp.current_ap_dev = dev
    wp.current_ap = ap

    local active_ap = dev:get_active_access_point()
    local is_connected = ap == active_ap

    local obscure = true
    local auto_connect = true

    -- Close button
    local close_button = wp.ap_menu:get_children_by_id("close-button")[1]
    widgets.add_tooltip(close_button, "Back to network list")
    close_button:buttons({
        awful.button({}, 1, function()
            self:close_ap_menu()
        end),
    })

    -- Title
    local title = wp.ap_menu:get_children_by_id("title")[1]
    title:set_markup(
        string.format(
            "<span foreground='%s'>%s</span>",
            widgets.WHITE,
            ap:get_ssid()
        )
    )

    -- Interface label
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
        -- === NOT CONNECTED: show password input + connect button ===
        local obscure_icon = wp.ap_menu:get_children_by_id("obscure-icon")[1]
        obscure_icon:set_image(
            gcolor.recolor_image(
                widgets.ICONS_PATH .. "eye-off.svg",
                widgets.WHITE
            )
        )
        obscure_icon:buttons({
            awful.button({}, 1, function()
                obscure = not obscure
                password_input:set_obscure(obscure)
                obscure_icon:set_image(
                    gcolor.recolor_image(
                        widgets.ICONS_PATH
                            .. (obscure and "eye-off.svg" or "eye.svg"),
                        widgets.WHITE
                    )
                )
            end),
        })

        local auto_connect_icon =
            wp.ap_menu:get_children_by_id("auto-connect-icon")[1]
        auto_connect_icon:set_image(widgets.ICONS.check)
        auto_connect_icon:buttons({
            awful.button({}, 1, function()
                auto_connect = not auto_connect
                auto_connect_icon:set_image(
                    gcolor.recolor_image(
                        widgets.ICONS_PATH
                            .. (auto_connect and "check.svg" or "check-off.svg"),
                        widgets.WHITE
                    )
                )
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

        -- Don't close on unfocus — user may be clicking auto-connect etc.
        password_input:on_unfocused(function() end)

        password_input:on_executed(function(_, input)
            client:connect_access_point(ap, input, auto_connect)
            self:close_ap_menu()
        end)

        password_widget.visible = true
        password_input:focus()
    else
        -- === CONNECTED: show disconnect button only ===
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

--- Close AP menu and return to interface list.
-- @tparam table self Page instance
-- @tparam[opt] boolean skip_refresh Skip UI rebuild (for use when hiding)
----------------------------------------------------------------------
function M.close_ap_menu(self, skip_refresh)
    local wp = self._private
    wp.current_ap_dev = nil
    wp.current_ap = nil

    local password_input = wp.ap_menu:get_children_by_id("password-input")[1]
    if password_input then
        password_input:unfocus()
        password_input:set_obscure(true)
    end

    if not skip_refresh and client and client:get_wireless_enabled() then
        M.refresh_interface_list(self)
    end
end

--- Full refresh: rebuild interface list + trigger scan on all wireless devices.
-- @tparam table self Page instance
----------------------------------------------------------------------
function M.refresh(self)
    M.refresh_interface_list(self)
    for _, dev in ipairs(client.wireless_devices or {}) do
        if dev.request_scan then
            dev:request_scan()
        end
    end
end

return M
