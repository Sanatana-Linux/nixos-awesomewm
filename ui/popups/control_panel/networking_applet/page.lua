--[[
Enhanced Network Management Page

Features:
- Interface cards with detailed state (IP, speed, type, MAC)
- WiFi AP list sorted: connected first, then by signal strength descending
- Comprehensive AP info (SSID, BSSID, security badge, band/channel, signal % and bars)
- Auto-scan on page open
- Ethernet support with speed display and wired disconnect button
- Graceful fallback when NM is unavailable or has no devices
- Descriptive empty/disabled states
- Tooltips on all interactive elements
- Proper close_ap_menu guard to avoid state leaks on hide
--]]

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gcolor = require("gears.color")
local gfs = require("gears.filesystem")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local modules = require("modules")
local dpi = beautiful.xresources.apply_dpi
local network = require("service.network")
local client = network.get_default()
local shapes = require("modules.shapes.init")
local applet_pages = require("modules.applet_pages")

local WHITE = applet_pages.WHITE
local FG_ALT = beautiful.fg_alt

local network_page = {}

-- Icons (recolored once at module load)
local ICONS_PATH = gfs.get_configuration_dir()
    .. "ui/popups/control_panel/networking_applet/icons/"

local function load_icon(path)
    return gcolor.recolor_image(path, WHITE)
end

local ICONS = {
    wifi = load_icon(ICONS_PATH .. "wifi.svg"),
    ethernet = load_icon(ICONS_PATH .. "ethernet.svg"),
    search = load_icon(ICONS_PATH .. "search.svg"),
    back = load_icon(ICONS_PATH .. "arrow-left.svg"),
    check = load_icon(ICONS_PATH .. "check.svg"),
    refresh = load_icon(ICONS_PATH .. "refresh.svg"),
}

-- Tooltip helper: attaches an awful.tooltip to one or more widgets
----------------------------------------------------------------------
local function add_tooltip(objects, text)
    if type(objects) ~= "table" then
        objects = { objects }
    end
    awful.tooltip({
        objects = objects,
        text = text,
        delay_show = 0.5,
        margins_leftright = 8,
        margins_topbottom = 4,
        bg = beautiful.bg_normal,
        fg = beautiful.fg_normal,
    })
end

-- Tagbar-style button: matches the taskbar/taglist button appearance
----------------------------------------------------------------------
-- Uses bg_gradient_button with bg_gradient_recessed on hover,
-- transparent border by default, subtle border on hover.
local function create_tagbar_button(args)
    local btn = wibox.widget({
        id = args.id,
        widget = wibox.container.background,
        shape = shapes.rrect(6),
        border_width = dpi(1),
        border_color = "transparent",
        bg = beautiful.bg_gradient_button,
        forced_width = dpi(40),
        forced_height = dpi(40),
        {
            widget = wibox.container.place,
            halign = "center",
            valign = "center",
            {
                widget = wibox.container.margin,
                margins = dpi(6),
                {
                    id = args.icon_id,
                    widget = wibox.widget.imagebox,
                    image = args.icon,
                    forced_height = dpi(20),
                    forced_width = dpi(20),
                    resize = true,
                },
            },
        },
    })

    btn:connect_signal("mouse::enter", function(w)
        w:set_bg(beautiful.bg_gradient_recessed)
        w:set_border_color(beautiful.fg .. "66")
    end)
    btn:connect_signal("mouse::leave", function(w)
        w:set_bg(beautiful.bg_gradient_button)
        w:set_border_color("transparent")
    end)

    return btn
end

-- Slider-style container: matches audio_slider / brightness_slider panels
----------------------------------------------------------------------
local function slider_container(content)
    local bg_color = beautiful.bg_alt or beautiful.bg_normal or "#222222"
    return wibox.widget({
        widget = wibox.container.background,
        bg = bg_color .. "aa",
        shape = shapes.rrect(10),
        border_width = dpi(1),
        border_color = beautiful.fg_alt,
        {
            widget = wibox.container.margin,
            margins = {
                left = dpi(20),
                right = dpi(20),
                top = dpi(10),
                bottom = dpi(10),
            },
            content,
        },
    })
end

-- Signal strength helpers
----------------------------------------------------------------------

-- Visual bar characters based on signal percentage
local function signal_bars(strength)
    if not strength then
        return ""
    end
    if strength > 70 then
        return "▂▄▆█"
    elseif strength > 45 then
        return "▂▄▆"
    elseif strength > 20 then
        return "▂▄"
    else
        return "▂"
    end
end

-- Short security label for badge display
local function security_badge(security)
    if not security or security == "" then
        return "Open"
    end
    if security:match("WPA3") then
        return "WPA3"
    elseif security:match("WPA2") then
        return "WPA2"
    elseif security:match("WPA1") then
        return "WPA"
    elseif security:match("WEP") then
        return "WEP"
    else
        return "Secured"
    end
end

-- Interface header widget
----------------------------------------------------------------------
-- Shows: icon, interface name, type, connection status/IP, MAC + speed
local function create_interface_header(dev, is_wireless)
    local interface_name = dev:get_interface() or "Unknown"
    local state = dev:get_state()
    local state_str = network.device_state_to_string(state) or "Unknown"
    local ip_addr = dev:get_ip4_address()
    local dev_type = dev:get_type_string()
    local hw_addr = dev:get_hw_address()
    local speed_str = dev:get_speed_string()

    local icon = is_wireless and ICONS.wifi or ICONS.ethernet
    local status_text
    if state == network.DeviceState.ACTIVATED then
        status_text = ip_addr and string.format("Connected  %s", ip_addr)
            or "Connected"
    else
        status_text = state_str
    end

    -- Detail line: MAC  ·  Speed (when connected)
    local details = {}
    if hw_addr then
        table.insert(details, hw_addr)
    end
    if
        speed_str
        and speed_str ~= ""
        and state == network.DeviceState.ACTIVATED
    then
        table.insert(details, speed_str)
    end
    local detail_str = #details > 0 and table.concat(details, "  ·  ") or ""

    return slider_container(wibox.widget({
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(3),
        {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(8),
            {
                widget = wibox.widget.imagebox,
                image = icon,
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
                    FG_ALT,
                    dev_type
                ),
            },
        },
        {
            widget = wibox.container.margin,
            margins = { left = dpi(22) },
            {
                widget = wibox.widget.textbox,
                markup = string.format(
                    "<span foreground='%s' font_size='small'>%s</span>",
                    state == network.DeviceState.ACTIVATED and beautiful.fg
                        or FG_ALT,
                    status_text
                ),
            },
        },
        {
            widget = wibox.container.margin,
            margins = { left = dpi(22) },
            visible = detail_str ~= "",
            {
                widget = wibox.widget.textbox,
                markup = string.format(
                    "<span foreground='%s' font_size='x-small'>%s</span>",
                    FG_ALT,
                    detail_str
                ),
            },
        },
    }))
end

-- Enhanced access-point widget
----------------------------------------------------------------------
-- Shows 3 rows: SSID + security badge | BSSID + band | signal bars + %
local function create_ap_widget(self, dev, ap)
    local ap_ssid = ap:get_ssid()
    local ap_strength = ap:get_strength()
    local active_ap = dev:get_active_access_point()
    local ap_is_active = ap == active_ap
    local security = ap:get_security()
    local bssid = ap:get_hw_address()
    local band = ap:get_frequency_band()
    local sec_badge = security_badge(security)

    local ap_widget = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg_alt .. "aa",
        shape = shapes.rrect(10),
        border_width = dpi(1),
        border_color = beautiful.fg_alt,
        forced_height = dpi(74),
        {
            widget = wibox.container.margin,
            margins = dpi(10),
            {
                layout = wibox.layout.fixed.vertical,
                spacing = dpi(3),
                -- Row 1: SSID + security badge
                {
                    layout = wibox.layout.align.horizontal,
                    {
                        layout = wibox.layout.fixed.horizontal,
                        spacing = dpi(6),
                        {
                            widget = wibox.widget.imagebox,
                            image = ICONS.check,
                            forced_height = dpi(14),
                            forced_width = dpi(14),
                            resize = true,
                            visible = ap_is_active,
                        },
                        {
                            widget = wibox.widget.textbox,
                            markup = string.format(
                                "<span foreground='%s' font_weight='bold'>%s</span>",
                                WHITE,
                                ap_ssid or "Unknown"
                            ),
                        },
                    },
                    nil,
                    {
                        widget = wibox.widget.textbox,
                        markup = string.format(
                            "<span foreground='%s' font_size='x-small'>%s</span>",
                            beautiful.orange,
                            sec_badge
                        ),
                    },
                },
                -- Row 2: BSSID + band
                {
                    layout = wibox.layout.align.horizontal,
                    {
                        widget = wibox.widget.textbox,
                        markup = string.format(
                            "<span foreground='%s' font_size='x-small'>%s</span>",
                            FG_ALT,
                            bssid or ""
                        ),
                    },
                    nil,
                    {
                        widget = wibox.widget.textbox,
                        markup = string.format(
                            "<span foreground='%s' font_size='x-small'>%s</span>",
                            FG_ALT,
                            band
                        ),
                        visible = band ~= "Unknown",
                    },
                },
                -- Row 3: Signal bars + percentage
                {
                    layout = wibox.layout.align.horizontal,
                    {
                        widget = wibox.widget.textbox,
                        markup = string.format(
                            "<span foreground='%s'>%s</span>",
                            WHITE,
                            signal_bars(ap_strength)
                        ),
                    },
                    nil,
                    {
                        widget = wibox.widget.textbox,
                        markup = string.format(
                            "<span foreground='%s' font_size='x-small'>%d%%</span>",
                            FG_ALT,
                            ap_strength or 0
                        ),
                    },
                },
            },
        },
    })

    ap_widget.active = ap_is_active
    ap_widget.dev = dev
    ap_widget.ap = ap

    applet_pages.setup_item_effects(ap_widget)

    ap_widget:buttons({
        awful.button({}, 1, function()
            self:open_ap_menu(dev, ap)
        end),
    })

    -- Tooltip with full connection info
    local tip_lines = { ap_ssid or "Unknown" }
    table.insert(tip_lines, "BSSID: " .. (bssid or "Unknown"))
    if ap_strength then
        table.insert(tip_lines, "Signal: " .. ap_strength .. "%")
    end
    table.insert(tip_lines, "Security: " .. sec_badge)
    table.insert(tip_lines, "Band: " .. band)
    local ch = ap:get_channel()
    if ch then
        table.insert(tip_lines, "Channel: " .. tostring(ch))
    end
    local freq = ap:get_frequency()
    if freq then
        table.insert(tip_lines, "Frequency: " .. tostring(freq) .. " MHz")
    end
    add_tooltip(ap_widget, table.concat(tip_lines, "\n"))

    return ap_widget
end

-- Refresh the interface / AP list
----------------------------------------------------------------------
-- Builds the content layout from scratch, sorting APs connected-first
-- then by signal strength descending.
local function refresh_interface_list(self)
    local wp = self._private
    local content_layout = self:get_children_by_id("content-layout")[1]

    wp.interface_widgets = {}
    wp.ap_widgets = {}

    -- Check NM availability
    if not client or not client.devices or #client.devices == 0 then
        content_layout:reset()
        content_layout:add(applet_pages.create_empty_state({
            icon = ICONS_PATH .. "search.svg",
            text = "No NetworkManager\ndevices found",
        }))
        return
    end

    -- WiFi disabled state
    if not client:get_wireless_enabled() then
        content_layout:reset()
        content_layout:add(applet_pages.create_empty_state({
            icon = ICONS_PATH .. "wifi.svg",
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
                margins = { top = dpi(4), bottom = dpi(2), left = dpi(4) },
                {
                    widget = wibox.widget.textbox,
                    markup = string.format(
                        "<span foreground='%s' font_size='x-small'>── %s ──</span>",
                        FG_ALT,
                        iface_name
                    ),
                },
            }))
        end

        local header = create_interface_header(dev, is_wireless)

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
                        local ap_w = create_ap_widget(self, dev, ap)
                        content_layout:add(ap_w)
                        table.insert(wp.ap_widgets, ap_w)
                    end
                elseif state ~= network.DeviceState.ACTIVATED then
                    -- No APs yet but device is not connected
                    content_layout:add(wibox.widget({
                        widget = wibox.container.margin,
                        margins = { left = dpi(24), bottom = dpi(8) },
                        {
                            widget = wibox.widget.textbox,
                            markup = string.format(
                                "<span foreground='%s' font_size='small'>Scanning for networks...</span>",
                                FG_ALT
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
            add_tooltip(
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
                margins = { left = dpi(24), right = dpi(24), bottom = dpi(8) },
                disconnect_btn,
            }))
        end
    end
end

-- Wireless enabled/disabled handler
----------------------------------------------------------------------
local function on_wireless_enabled(self, enabled)
    local wp = self._private
    local content_layout = self:get_children_by_id("content-layout")[1]

    if enabled then
        refresh_interface_list(self)
    else
        wp.interface_widgets = {}
        wp.ap_widgets = {}
        content_layout:reset()
        content_layout:add(applet_pages.create_empty_state({
            icon = ICONS_PATH .. "wifi.svg",
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

-- AP connection menu
----------------------------------------------------------------------
function network_page:open_ap_menu(dev, ap)
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
    add_tooltip(close_button, "Back to network list")
    close_button:buttons({
        awful.button({}, 1, function()
            self:close_ap_menu()
        end),
    })

    -- Title
    local title = wp.ap_menu:get_children_by_id("title")[1]
    title:set_markup(
        string.format("<span foreground='%s'>%s</span>", WHITE, ap:get_ssid())
    )

    -- Interface label
    local interface_label = wp.ap_menu:get_children_by_id("interface-label")[1]
    if interface_label then
        interface_label:set_markup(
            string.format(
                "<span foreground='%s'>Interface: %s</span>",
                FG_ALT,
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
            gcolor.recolor_image(ICONS_PATH .. "eye-off.svg", WHITE)
        )
        obscure_icon:buttons({
            awful.button({}, 1, function()
                obscure = not obscure
                password_input:set_obscure(obscure)
                obscure_icon:set_image(
                    gcolor.recolor_image(
                        ICONS_PATH .. (obscure and "eye-off.svg" or "eye.svg"),
                        WHITE
                    )
                )
            end),
        })

        local auto_connect_icon =
            wp.ap_menu:get_children_by_id("auto-connect-icon")[1]
        auto_connect_icon:set_image(ICONS.check)
        auto_connect_icon:buttons({
            awful.button({}, 1, function()
                auto_connect = not auto_connect
                auto_connect_icon:set_image(
                    gcolor.recolor_image(
                        ICONS_PATH
                            .. (auto_connect and "check.svg" or "check-off.svg"),
                        WHITE
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

-- Close AP menu and return to interface list
----------------------------------------------------------------------
-- @param skip_refresh: if true, skip UI updates (for use when hiding)
function network_page:close_ap_menu(skip_refresh)
    local wp = self._private
    wp.current_ap_dev = nil
    wp.current_ap = nil

    local password_input = wp.ap_menu:get_children_by_id("password-input")[1]
    if password_input then
        password_input:unfocus()
        password_input:set_obscure(true)
    end

    if not skip_refresh and client and client:get_wireless_enabled() then
        refresh_interface_list(self)
    end
end

-- Full refresh: rebuild list + trigger scan on all wireless devices
----------------------------------------------------------------------
function network_page:refresh()
    refresh_interface_list(self)
    for _, dev in ipairs(client.wireless_devices or {}) do
        if dev.request_scan then
            dev:request_scan()
        end
    end
end

-- Constructor
----------------------------------------------------------------------
local function new()
    -- Create bottom bar buttons with direct references
    local toggle_btn = create_tagbar_button({
        icon_id = "bottombar-toggle-icon",
        icon = gcolor.recolor_image(ICONS_PATH .. "wifi.svg", WHITE),
    })
    local refresh_btn = create_tagbar_button({
        icon_id = "bottombar-refresh-icon",
        icon = gcolor.recolor_image(ICONS_PATH .. "refresh.svg", WHITE),
    })
    local close_btn = create_tagbar_button({
        icon_id = "bottombar-close-icon",
        icon = gcolor.recolor_image(ICONS_PATH .. "arrow-left.svg", WHITE),
    })

    local ret = applet_pages.create_base_page({
        left_buttons = { toggle_btn, refresh_btn },
        right_buttons = { close_btn },
    })

    gtable.crush(ret, network_page, true)
    local wp = ret._private
    wp.interface_widgets = {}
    wp.ap_widgets = {}
    wp.current_ap_dev = nil
    wp.current_ap = nil

    -- Build the AP connection menu widget tree
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
                    image = ICONS.back,
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
                bg = beautiful.bg_alt .. "aa",
                shape = shapes.rrect(10),
                border_width = dpi(1),
                border_color = beautiful.fg_alt,
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
                                            placeholder_fg = FG_ALT,
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
            {
                id = "connect-disconnect-button",
                widget = wibox.container.background,
                shape = shapes.rrect(6),
                border_width = dpi(1),
                border_color = "transparent",
                bg = beautiful.bg_gradient_button,
                {
                    widget = wibox.container.margin,
                    margins = dpi(10),
                    {
                        id = "connect-disconnect-label",
                        widget = wibox.widget.textbox,
                        align = "center",
                        markup = string.format(
                            "<span foreground='%s'>Connect</span>",
                            WHITE
                        ),
                    },
                },
            },
        },
    })

    -- Bottom bar: WiFi toggle button
    add_tooltip(toggle_btn, "Toggle WiFi on/off")
    toggle_btn:buttons({
        awful.button({}, 1, function()
            if client then
                client:set_wireless_enabled(not client:get_wireless_enabled())
            end
        end),
    })

    -- Bottom bar: Refresh / scan button
    add_tooltip(refresh_btn, "Scan for available networks")
    refresh_btn:buttons({
        awful.button({}, 1, function()
            if client and client:get_wireless_enabled() then
                ret:refresh()
            end
        end),
    })

    -- Bottom bar: Back button
    wp.close_btn = close_btn
    add_tooltip(close_btn, "Back to control panel")

    -- AP menu: connect/disconnect action button
    local action_btn =
        wp.ap_menu:get_children_by_id("connect-disconnect-button")[1]
    action_btn:connect_signal("mouse::enter", function(w)
        w:set_bg(beautiful.bg_gradient_recessed)
        w:set_border_color(beautiful.fg .. "66")
    end)
    action_btn:connect_signal("mouse::leave", function(w)
        w:set_bg(beautiful.bg_gradient_button)
        w:set_border_color("transparent")
    end)
    add_tooltip(action_btn, "Connect or disconnect from this network")

    -- attach a helper to set the label text
    function action_btn:set_label(label)
        local lbl = self:get_children_by_id("connect-disconnect-label")[1]
        lbl:set_markup(
            string.format("<span foreground='%s'>%s</span>", WHITE, label)
        )
    end

    -- Signal wiring: wireless device events
    for _, dev in ipairs(client.wireless_devices or {}) do
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

    -- Signal wiring: wired device events
    for _, dev in ipairs(client.wired_devices or {}) do
        dev:connect_signal("property::state", function(_, state)
            if
                state == network.DeviceState.ACTIVATED
                or state == network.DeviceState.DISCONNECTED
            then
                refresh_interface_list(ret)
            end
        end)
    end

    -- Global wireless-enabled signal
    client:connect_signal("property::wireless-enabled", function(_, enabled)
        on_wireless_enabled(ret, enabled)
    end)

    -- Initial render
    on_wireless_enabled(ret, client:get_wireless_enabled())

    -- Auto-scan shortly after creation
    gtimer.delayed_call(function()
        if client then
            ret:refresh()
        end
    end)

    return ret
end

-- Singleton access
----------------------------------------------------------------------
local instance = nil
local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return setmetatable({
    new = new,
    get_default = get_default,
}, {
    __call = function(_, ...)
        return new(...)
    end,
})
