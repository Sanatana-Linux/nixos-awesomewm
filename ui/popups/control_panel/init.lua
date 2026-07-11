local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local dpi = beautiful.xresources.apply_dpi
local anim = require("modules.animations")
local capi = { screen = screen }
local shapes = require("modules.shapes")
local notification_list = require("ui.popups.control_panel.notification_list")
local audio_sliders = require("ui.popups.control_panel.audio_sliders")
local brightness_slider = require("ui.popups.control_panel.brightness_slider")
local network_button =
    require("ui.popups.control_panel.networking_applet.button")
local network_page = require("ui.popups.control_panel.networking_applet.page")
local bluetooth_button =
    require("ui.popups.control_panel.bluetooth_applet.button")
local bluetooth_page = require("ui.popups.control_panel.bluetooth_applet.page")
local audio = require("service.audio").get_default()
local click_to_hide = require("modules.click_to_hide")

-- Tooltip helper
local function add_tooltip(widget, text)
    awful.tooltip({
        objects = { widget },
        text = text,
        delay_show = 0.5,
        margins_leftright = 8,
        margins_topbottom = 4,
    })
end

local control_panel = {}

function control_panel:setup_network_page()
    local wp = self._private
    local main_layout = self.widget:get_children_by_id("main-layout")[1]
    main_layout:reset()
    main_layout:add(wp.network_page)
end

function control_panel:setup_bluetooth_page()
    local wp = self._private
    local main_layout = self.widget:get_children_by_id("main-layout")[1]
    main_layout:reset()
    main_layout:add(wp.bluetooth_page)
end

function control_panel:setup_main_page()
    local wp = self._private
    local main_layout = self.widget:get_children_by_id("main-layout")[1]
    main_layout:reset()
    main_layout:add(
        wp.notification_list,
        wibox.widget({
            widget = wibox.container.background,
            forced_width = 1,
            forced_height = beautiful.separator_thickness,
            {
                widget = wibox.widget.separator,
                orientation = "horizontal",
            },
        }),
        wp.audio_sliders,
        wp.brightness_slider,
        wibox.widget({
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(6),
            wp.network_button,
            wp.bluetooth_button,
        })
    )
end

function control_panel:show()
    local wp = self._private
    if wp.shown then
        return
    end

    wp.shown = true

    audio:get_default_sink_data()
    audio:get_default_source_data()
    self:setup_main_page()

    self.opacity = 0
    self.visible = true

    gtimer.delayed_call(function()
        local placement_func = self.placement
        if placement_func then
            placement_func(self)
        end

        gtimer.delayed_call(function()
            self:emit_signal("widget::layout_changed")

            local final_y = self.y
            local start_y = final_y + dpi(20)
            self.y = start_y

            anim.animate({
                start = 0,
                target = 1,
                duration = 0.3,
                easing = anim.easing.quadratic,
                update = function(progress)
                    self.opacity = progress
                    self.y = start_y + (final_y - start_y) * progress
                end,
                complete = function()
                    self:emit_signal("property::shown", wp.shown)
                end,
            })
        end)
    end)
end

function control_panel:hide()
    local wp = self._private
    if not wp.shown then
        return
    end
    wp.shown = false

    -- skip_refresh: no need to rebuild the UI when the popup is hiding
    wp.network_page:close_ap_menu(true)

    local start_y = self.y
    local final_y = start_y + dpi(20)

    anim.animate({
        start = 1,
        target = 0,
        duration = 0.3,
        easing = anim.easing.quadratic,
        update = function(progress)
            self.opacity = progress
            self.y = final_y - (final_y - start_y) * progress
        end,
        complete = function()
            self.visible = false
            self:emit_signal("property::shown", wp.shown)
        end,
    })
end

function control_panel:toggle()
    if not self.visible then
        self:show()
    else
        self:hide()
    end
end

function control_panel:show_network()
    local wp = self._private
    if not wp.shown then
        self:show()
    end
    self:setup_network_page()
    wp.network_page:refresh()
end

function control_panel:show_bluetooth()
    local wp = self._private
    if not wp.shown then
        self:show()
    end
    self:setup_bluetooth_page()
end

local function new()
    local ret = awful.popup({
        visible = false,
        ontop = true,
        screen = capi.screen.primary,
        bg = "#00000000",
        name = "awesome-popup",
        placement = function(c)
            awful.placement.bottom_right(c, {
                honor_workarea = true,
                margins = {
                    bottom = (c.screen.bar and c.screen.bar.height or 0)
                        + (beautiful.useless_gap or 0),
                },
            })
        end,
        widget = {
            widget = wibox.container.background,
            bg = beautiful.bg .. "55",
            border_width = beautiful.border_width,
            border_color = beautiful.border_color_normal,
            shape = shapes.rrect(20),
            {
                widget = wibox.container.margin,
                margins = dpi(12),
                {
                    id = "main-layout",
                    layout = wibox.layout.fixed.vertical,
                    spacing = dpi(6),
                },
            },
        },
    })

    gtable.crush(ret, control_panel, true)
    local wp = ret._private

    wp.notification_list = notification_list()
    wp.audio_sliders = audio_sliders()
    wp.brightness_slider = brightness_slider()
    wp.network_button = network_button()
    wp.network_page = network_page()
    wp.bluetooth_button = bluetooth_button()
    wp.bluetooth_page = bluetooth_page()

    -- Network button tooltips + reveal action
    local network_reveal =
        wp.network_button:get_children_by_id("reveal-button")[1]
    add_tooltip(network_reveal, "Open network settings")
    network_reveal:buttons({
        awful.button({}, 1, function()
            ret:setup_network_page()
            -- Trigger WiFi scan when opening the network page
            wp.network_page:refresh()
        end),
    })

    -- Network toggle tooltip
    local network_toggle =
        wp.network_button:get_children_by_id("toggle-button")[1]
    if network_toggle then
        add_tooltip(network_toggle, "Toggle WiFi on/off")
    end

    -- Network page back button
    local np_wp = wp.network_page._private
    if np_wp.close_btn then
        np_wp.close_btn:buttons({
            awful.button({}, 1, function()
                ret:setup_main_page()
            end),
        })
    end

    -- Bluetooth button tooltips + reveal action
    local bt_reveal = wp.bluetooth_button:get_children_by_id("reveal-button")[1]
    add_tooltip(bt_reveal, "Open Bluetooth settings")
    bt_reveal:buttons({
        awful.button({}, 1, function()
            ret:setup_bluetooth_page()
        end),
    })

    local bt_toggle = wp.bluetooth_button:get_children_by_id("toggle-button")[1]
    if bt_toggle then
        add_tooltip(bt_toggle, "Toggle Bluetooth on/off")
    end

    local bt_wp = wp.bluetooth_page._private
    if bt_wp.close_btn then
        bt_wp.close_btn:buttons({
            awful.button({}, 1, function()
                ret:setup_main_page()
            end),
        })
    end

    click_to_hide.popup(ret, function()
        ret:hide()
    end, { outside_only = true, exclusive = true })

    return ret
end

local instance = nil
local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return {
    get_default = get_default,
}
