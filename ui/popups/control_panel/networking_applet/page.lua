--[[
Networking applet page — main entry point.

Orchestrates widget construction and state management. The constructor
builds the full widget tree, wires device signals, and attaches state
methods. Callers use new() / get_default() / __call -- the public API
is unchanged.
--]]

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gcolor = require("gears.color")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local modules = require("modules")
local shapes = require("modules.style.shapes.init")
local dpi = beautiful.xresources.apply_dpi
local network = require("service.network")
local client = network.get_default()
local applet_pages = require("modules.infra.applet_pages")
local widgets = require("ui.popups.control_panel.networking_applet.widgets")
local state = require("ui.popups.control_panel.networking_applet.state")

local network_page = {}

-- Attach state management methods to the public interface.
-- These delegate to state.lua and operate on the page instance (self).
----------------------------------------------------------------------
gtable.crush(network_page, state, true)

-- Constructor
----------------------------------------------------------------------
local function new()
    -- Bottom bar buttons
    local toggle_btn = widgets.create_tagbar_button({
        icon_id = "bottombar-toggle-icon",
        icon = gcolor.recolor_image(
            widgets.ICONS_PATH .. "wifi.svg",
            widgets.WHITE
        ),
    })
    local refresh_btn = widgets.create_tagbar_button({
        icon_id = "bottombar-refresh-icon",
        icon = gcolor.recolor_image(
            widgets.ICONS_PATH .. "refresh.svg",
            widgets.WHITE
        ),
    })
    local close_btn = widgets.create_tagbar_button({
        icon_id = "bottombar-close-icon",
        icon = gcolor.recolor_image(
            widgets.ICONS_PATH .. "arrow-left.svg",
            widgets.WHITE
        ),
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
                    image = widgets.ICONS.back,
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
            margins = {
                left = dpi(15),
                right = dpi(15),
                bottom = dpi(5),
            },
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
                            margins = {
                                left = dpi(10),
                                right = dpi(10),
                            },
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
                                            cursor_bg = widgets.WHITE,
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
                                color = widgets.WHITE,
                            },
                        },
                        {
                            widget = wibox.container.margin,
                            margins = {
                                left = dpi(10),
                                right = dpi(10),
                            },
                            {
                                layout = wibox.layout.align.horizontal,
                                {
                                    widget = wibox.widget.textbox,
                                    markup = string.format(
                                        "<span foreground='%s'>Auto connect</span>",
                                        widgets.WHITE
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
                            widgets.WHITE
                        ),
                    },
                },
            },
        },
    })

    -- Bottom bar: WiFi toggle button
    widgets.add_tooltip(toggle_btn, "Toggle WiFi on/off")
    toggle_btn:buttons({
        awful.button({}, 1, function()
            if client then
                client:set_wireless_enabled(not client:get_wireless_enabled())
            end
        end),
    })

    -- Bottom bar: Refresh / scan button
    widgets.add_tooltip(refresh_btn, "Scan for available networks")
    refresh_btn:buttons({
        awful.button({}, 1, function()
            if client and client:get_wireless_enabled() then
                ret:refresh()
            end
        end),
    })

    -- Bottom bar: Back button
    wp.close_btn = close_btn
    widgets.add_tooltip(close_btn, "Back to control panel")

    -- AP menu: connect/disconnect action button hover effects
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
    widgets.add_tooltip(action_btn, "Connect or disconnect from this network")

    --- Helper to set the label on the connect/disconnect action button.
    function action_btn:set_label(label)
        local lbl = self:get_children_by_id("connect-disconnect-label")[1]
        lbl:set_markup(
            string.format(
                "<span foreground='%s'>%s</span>",
                widgets.WHITE,
                label
            )
        )
    end

    -- Signal wiring: wireless device events
    for _, dev in ipairs(client.wireless_devices or {}) do
        dev:connect_signal("property::access-points", function()
            state.refresh_interface_list(ret)
        end)
        dev:connect_signal("property::state", function(_, val)
            if
                val == network.DeviceState.ACTIVATED
                or val == network.DeviceState.DISCONNECTED
            then
                state.refresh_interface_list(ret)
            end
        end)
    end

    -- Signal wiring: wired device events
    for _, dev in ipairs(client.wired_devices or {}) do
        dev:connect_signal("property::state", function(_, val)
            if
                val == network.DeviceState.ACTIVATED
                or val == network.DeviceState.DISCONNECTED
            then
                state.refresh_interface_list(ret)
            end
        end)
    end

    -- Global wireless-enabled signal
    client:connect_signal("property::wireless-enabled", function(_, enabled)
        state.on_wireless_enabled(ret, enabled)
    end)

    -- Initial render
    state.on_wireless_enabled(ret, client:get_wireless_enabled())

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
