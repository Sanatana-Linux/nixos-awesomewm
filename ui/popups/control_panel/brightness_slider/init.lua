--- Brightness slider widget for the control panel.
-- Provides a slider + icon + percentage label, debounced to avoid glitching
-- on rapid changes. Syncs with the brightness service bidirectionally.
-- @module ui.popups.control_panel.brightness_slider

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local brightness_service = require("service.brightness").get_default()
local shapes = require("modules.style.shapes.init")
local gtimer = require("gears.timer")

--- Construct a new brightness slider widget.
-- Creates a slider with icon and percentage label, wires debounced set calls,
-- and listens for external brightness changes from the service.
-- @treturn wibox.widget The brightness slider composite widget
-- @local
local function new()
    local slider = wibox.widget({
        id = "brightness_slider",
        widget = wibox.widget.slider,
        maximum = 100,
        minimum = 0,
        value = 50, -- Initial value
        bar_height = dpi(2),
        handle_width = dpi(20),
        handle_border_width = dpi(2),
        handle_margins = { top = dpi(7), bottom = dpi(7) },
        bar_color = beautiful.bg_urg .. "aa",
        bar_active_color = beautiful.ac,
        handle_color = beautiful.bg_alt .. "aa",
        handle_border_color = beautiful.ac,
        handle_shape = shapes.circle(9),
        bar_shape = shapes.rbar(),
    })

    local icon = wibox.widget({
        id = "brightness_icon",
        widget = wibox.widget.textbox,
        markup = "󰃟", -- Default brightness icon
        align = "center",
    })

    local value_label = wibox.widget({
        id = "brightness_value",
        widget = wibox.widget.textbox,
        markup = "50%",
        align = "center",
    })

    -- Debounced brightness setter to avoid glitching on rapid slider moves.
    -- Uses a 100ms timer to debounce.
    -- @tparam number value 0..100
    -- @local
    local function set_brightness_debounced(value)
        last_brightness_value = value

        -- Cancel existing timer
        if brightness_timer then
            brightness_timer:stop()
        end

        -- Set up new debounced timer
        brightness_timer = gtimer.start_new(0.1, function() -- 100ms delay
            brightness_service:set(last_brightness_value)
            brightness_timer = nil
            return false -- Don't repeat
        end)
    end

    slider:connect_signal("property::value", function(_, new_value)
        set_brightness_debounced(new_value)
    end)

    -- Update widget state when brightness changes externally
    brightness_service:connect_signal("brightness::updated", function(_, value)
        slider:set_value(value)
        value_label:set_markup(string.format("%d%%", value))
        -- Update icon based on brightness level
        local brightness_icon
        if value > 90 then
            brightness_icon = "󰃠"
        elseif value > 60 then
            brightness_icon = "󰃟"
        elseif value > 30 then
            brightness_icon = "󰃝"
        elseif value > 10 then
            brightness_icon = "󰃞"
        else
            brightness_icon = "󰃞"
        end
        icon:set_markup(brightness_icon)
    end)

    -- Set initial state from the service
    local initial_brightness = brightness_service:get()
    if initial_brightness then
        slider:set_value(initial_brightness)
        value_label:set_markup(string.format("%d%%", initial_brightness))
        -- Set initial icon
        local brightness_icon
        if initial_brightness > 90 then
            brightness_icon = "󰃠"
        elseif initial_brightness > 60 then
            brightness_icon = "󰃟"
        elseif initial_brightness > 30 then
            brightness_icon = "󰃝"
        elseif initial_brightness > 10 then
            brightness_icon = "󰃞"
        else
            brightness_icon = "󰃞"
        end
        icon:set_markup(brightness_icon)
    end

    return wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg_alt .. "aa",
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
            {
                layout = wibox.layout.fixed.horizontal,
                fill_space = true,
                spacing = dpi(20),
                icon,
                {
                    widget = wibox.container.background,
                    forced_width = dpi(310),
                    forced_height = dpi(40),
                    slider,
                },
                value_label,
            },
        },
    })
end

return setmetatable({
    new = new,
}, {
    __call = new,
})
