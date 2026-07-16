--[[
Networking applet widget builders.

Pure UI functions — no state management. Each function takes the data it
needs as parameters and returns a fully constructed widget. Used by state.lua
and page.lua for the network management page.
--]]

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gcolor = require("gears.color")
local gfs = require("gears.filesystem")
local shapes = require("modules.style.shapes.init")
local applet_pages = require("modules.infra.applet_pages")
local network = require("service.network")
local dpi = beautiful.xresources.apply_dpi

local M = {}

local WHITE = applet_pages.WHITE
local FG_ALT = beautiful.fg_alt

-- Icon preloading (recolored once at module load)
----------------------------------------------------------------------
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

-- Expose for page.lua and state.lua
----------------------------------------------------------------------
M.ICONS = ICONS
M.ICONS_PATH = ICONS_PATH
M.WHITE = WHITE

--- Attach a themed tooltip to one or more widgets.
-- @tparam table|widget objects Single widget or list of widgets
-- @tparam string text Tooltip text
----------------------------------------------------------------------
function M.add_tooltip(objects, text)
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

--- Tagbar-style button: matches the taskbar/taglist button appearance.
-- Uses bg_gradient_button with bg_gradient_recessed on hover,
-- transparent border by default, subtle border on hover.
-- @tparam table args Configuration with id, icon_id, icon
-- @treturn table Wibox button widget
----------------------------------------------------------------------
function M.create_tagbar_button(args)
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

--- Slider-style container: matches audio_slider / brightness_slider panels.
-- @tparam widget content The inner widget to wrap
-- @treturn table Wibox container widget
----------------------------------------------------------------------
function M.slider_container(content)
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

--- Visual bar characters based on signal percentage.
-- @tparam number strength Signal percentage (0-100)
-- @treturn string Unicode bar characters
----------------------------------------------------------------------
function M.signal_bars(strength)
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

--- Short security label for badge display.
-- @tparam string security Raw security string from NM
-- @treturn string Short label (WPA3, WPA2, WPA, WEP, Open, Secured)
----------------------------------------------------------------------
function M.security_badge(security)
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

--- Interface header widget.
-- Shows: icon, interface name, type, connection status/IP, MAC + speed.
-- @tparam table dev NetworkManager device object
-- @tparam boolean is_wireless Whether the device is a WiFi interface
-- @treturn table Wibox widget
----------------------------------------------------------------------
function M.create_interface_header(dev, is_wireless)
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

    return M.slider_container(wibox.widget({
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

--- Access-point widget: SSID + security badge, BSSID + band, signal bars.
-- @tparam table dev NetworkManager device object
-- @tparam table ap Access-point object
-- @tparam function on_click Callback when the AP widget is clicked
-- @treturn table Wibox clickable AP widget
----------------------------------------------------------------------
function M.create_ap_widget(dev, ap, on_click)
    local ap_ssid = ap:get_ssid()
    local ap_strength = ap:get_strength()
    local active_ap = dev:get_active_access_point()
    local ap_is_active = ap == active_ap
    local security = ap:get_security()
    local bssid = ap:get_hw_address()
    local band = ap:get_frequency_band()
    local sec_badge = M.security_badge(security)

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
                            M.signal_bars(ap_strength)
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
            if on_click then
                on_click()
            end
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
    M.add_tooltip(ap_widget, table.concat(tip_lines, "\n"))

    return ap_widget
end

return M
