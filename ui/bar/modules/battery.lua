-- ui/bar/modules/battery.lua
-- This module defines the graphical battery widget for the wibar, combining a
-- visual progressbar with a text overlay, button styling, and a themed tooltip.

local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local dpi = beautiful.xresources.apply_dpi
local battery_service = require("service.battery").get_default()
local modules = require("modules")
local text_icons = beautiful.text_icons
local shapes = require('modules.shapes.init')

return function()
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

    -- The progressbar that acts as the battery body
    local progressbar = wibox.widget({
        id = "progressbar",
        widget = wibox.widget.progressbar,
        max_value = 100,
        paddings = dpi(3),
        border_width = dpi(1.25),
        shape = shapes.rrect(5),
        bar_shape = shapes.rrect(2),
        border_color = beautiful.fg .. "99",
        background_color = beautiful.bg_alt,
        color = beautiful.blue, -- Default color
    })

    -- The text label for the percentage, overlaid on the progressbar
    local percentage_label = wibox.widget({
        id = "percentage",
        font = beautiful.font_h0,
        color = beautiful.bg,
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
    })

    -- The icon to show when charging, also overlaid
    local charging_icon = wibox.widget({
        id = "charging_icon",
        markup = text_icons.bolt or "",
        color = beautiful.bg,
        visible = false, -- Initially hidden
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
    })

    -- Use a stack layout to overlay the text and charging icon on the progressbar
    local stacked_layout = wibox.widget({
        layout = wibox.layout.stack,
        forced_height = dpi(22),
        forced_width = dpi(30),
        progressbar,
        percentage_label,
        charging_icon,
    })

    -- The small widget representing the battery terminal
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

    -- Create the main button container using hover_button for styling and effects
    local widget = modules.hover_button({
        bg_normal = beautiful.bg_gradient_button,
        bg_hover = beautiful.bg_gradient_button_alt,
        shape = shapes.rrect(8),
        child_widget = {
            widget = wibox.container.margin,
            margins = { top = dpi(4), bottom = dpi(4), left = dpi(4), right = dpi(4) },
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(3),
                stacked_layout,
                terminal,
            },
        },
    })

    -- Attach the tooltip to the main widget
    battery_tooltip:add_to_object(widget)

    -- Function to update all visual elements and the tooltip
    local function update_all()
        local level = battery_service.level or 0
        local is_charging = battery_service.is_charging or false

        -- Update progressbar value and color
        progressbar:set_value(level)
        if level > 70 then
            progressbar.color = beautiful.green
        elseif level > 20 then
            progressbar.color = beautiful.yellow
        else
            progressbar.color = beautiful.red
        end

        -- Update text/icon visibility
        charging_icon.visible = is_charging
        percentage_label.visible = not is_charging
        percentage_label:set_text(string.format("%d%%", level))

        -- Update tooltip text
        local status_text = is_charging and "Charging" or "Discharging"
        battery_tooltip:set_text(
            string.format("Status: %s\nLevel: %d%%", status_text, level)
        )
    end

    -- Connect signals to update the widget
    battery_service:connect_signal("property::level", update_all)
    battery_service:connect_signal("property::is_charging", update_all)

    -- Initial update
    battery_service:update()
    gears.timer.delayed_call(update_all)

    return widget
end
