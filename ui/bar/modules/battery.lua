local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local gears = require("gears")
local gfs = require("gears.filesystem")
local dpi = beautiful.xresources.apply_dpi
local modules = require("modules")
local text_icons = beautiful.text_icons
local shapes = require("modules.shapes.init")

local function has_battery()
    local handle = io.open("/sys/class/power_supply/BAT0/capacity", "r")
    if handle then
        handle:close()
        return true
    end
    return false
end

local function create_battery_widget()
    local battery_service = require("service.battery").get_default()
    local battery_popup = require("ui.popups.battery").get_default()

    local battery_tooltip = awful.tooltip({
        align = "left",
        mode = "outside",
        preferred_positions = { "top" },
        bg = beautiful.bg_normal,
        fg = beautiful.fg_normal,
        shape = shapes.rrect(8),
        border_width = beautiful.border_width,
        border_color = beautiful.border_color,
        font = beautiful.font,
    })

    local progressbar = wibox.widget({
        id = "progressbar",
        widget = wibox.widget.progressbar,
        max_value = 100,
        forced_width = dpi(30),
        paddings = dpi(3),
        border_width = dpi(1.25),
        shape = shapes.rrect(5),
        bar_shape = shapes.rrect(2),
        border_color = beautiful.fg .. "99",
        background_color = beautiful.bg_alt,
        color = beautiful.blue,
    })

    local bolt_icon = gfs.get_configuration_dir()
        .. "themes/kailash/icons/wibar/bolt.svg"

    local percentage_label = wibox.widget({
        id = "percentage",
        font = beautiful.font_name .. dpi(9),
        color = "#ffffff",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
    })

    local charging_icon = wibox.widget({
        widget = wibox.container.place,
        visible = false,
        halign = "center",
        valign = "center",
        {
            id = "charging_icon_img",
            image = gears.color.recolor_image(bolt_icon, beautiful.yellow),
            forced_height = dpi(16),
            forced_width = dpi(16),
            resize = true,
            widget = wibox.widget.imagebox,
        },
    })

    local info_stack = wibox.widget({
        layout = wibox.layout.stack,
        forced_width = dpi(32),
        percentage_label,
        charging_icon,
    })

    local terminal = wibox.widget({
        widget = wibox.container.place,
        valign = "center",
        {
            bg = beautiful.fg .. "99",
            forced_height = dpi(7),
            forced_width = dpi(1),
            shape = shapes.rrect(10),
            widget = wibox.container.background,
        },
    })

    local battery_layout = wibox.widget({
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(3),
        forced_height = dpi(22),
        forced_width = dpi(72),
        progressbar,
        terminal,
        info_stack,
    })

    local widget = modules.hover_button({
        bg_normal = beautiful.bg_gradient_button,
        bg_hover = beautiful.bg_gradient_button_alt,
        border_width = dpi(1),
        border_color_normal = beautiful.fg .. "00",
        border_hover = beautiful.fg .. "66",
        shape = shapes.rrect(8),
        child_widget = {
            widget = wibox.container.margin,
            margins = {
                top = dpi(4),
                bottom = dpi(4),
                left = dpi(8),
                right = dpi(4),
            },
            battery_layout,
        },
    })

    battery_tooltip:add_to_object(widget)

    widget:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            battery_popup:toggle()
        end
    end)

    local function update_all()
        local level = battery_service.level or 0
        local is_charging = battery_service.is_charging or false

        progressbar:set_value(level)
        if level > 70 then
            progressbar.color = beautiful.green
        elseif level > 20 then
            progressbar.color = beautiful.yellow
        else
            progressbar.color = beautiful.red
        end

        charging_icon.visible = is_charging
        percentage_label.visible = not is_charging
        percentage_label:set_text(string.format("%d%%", level))

        local status_text = is_charging and "Charging" or "Discharging"
        battery_tooltip:set_text(
            string.format("Status: %s\nLevel: %d%%", status_text, level)
        )
    end

    battery_service:connect_signal("property::level", update_all)
    battery_service:connect_signal("property::is_charging", update_all)

    battery_service:update()
    gears.timer.delayed_call(update_all)

    return widget
end

local function create_cpu_widget()
    local system_info = require("service.system_info").get_default()
    local battery_popup = require("ui.popups.battery").get_default()
    local arc_chart = require("modules.arc_chart")

    local cpu_chart = arc_chart.new({
        value = 0,
        label = "CPU",
        color = beautiful.red or "#f7768e",
        thickness = dpi(6),
        margins = dpi(2),
    })

    local cpu_tooltip = awful.tooltip({
        align = "left",
        mode = "outside",
        preferred_positions = { "top" },
        bg = beautiful.bg_normal,
        fg = beautiful.fg_normal,
        shape = shapes.rrect(8),
        border_width = beautiful.border_width,
        border_color = beautiful.border_color,
        font = beautiful.font,
    })

    local widget = modules.hover_button({
        bg_normal = beautiful.bg_gradient_button,
        bg_hover = beautiful.bg_gradient_button_alt,
        border_width = dpi(1),
        border_color_normal = beautiful.fg .. "00",
        border_hover = beautiful.fg .. "66",
        shape = shapes.rrect(8),
        child_widget = {
            widget = wibox.container.margin,
            margins = dpi(2),
            cpu_chart,
        },
    })

    cpu_tooltip:add_to_object(widget)
    cpu_tooltip:set_text("No battery detected — showing CPU usage")

    widget:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            battery_popup:toggle()
        end
    end)

    local function update_chart()
        local cpu = system_info:get_cpu_usage()
        cpu_chart:set_value(cpu, false)
    end

    system_info:connect_signal("property::cpu_usage", update_chart)
    gears.timer.delayed_call(update_chart)

    return widget
end

if has_battery() then
    return create_battery_widget
else
    return create_cpu_widget
end
