-- ui/control_panel/audio_sliders/init.lua
-- This module provides sliders for controlling system volume and microphone input.
-- The brightness slider has been moved to its own module.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local modules = require("modules")
local shapes = require("modules.shapes.init")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local audio_service = require("service.audio").get_default()

local function new()
    local ret = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg_alt,
        shape = shapes.rrect(10),
        {
            widget = wibox.container.margin,
            margins = {
                left = dpi(20),
                right = dpi(20),
                top = dpi(10),
                bottom = dpi(10),
            },
            {
                layout = wibox.layout.fixed.vertical,
                spacing = dpi(5),
                -- Speaker (Volume) Slider
                {
                    layout = wibox.layout.fixed.horizontal,
                    fill_space = true,
                    spacing = dpi(20),
                    {
                        id = "speaker-icon",
                        widget = wibox.widget.textbox,
                        align = "center",
                    },
                    {
                        widget = wibox.container.background,
                        forced_width = dpi(310),
                        forced_height = dpi(40),
                        {
                            id = "speaker-slider",
                            widget = wibox.widget.slider,
                            maximum = 100,
                            bar_height = dpi(2),
                            handle_width = dpi(20),
                            handle_border_width = dpi(2),
                            handle_margins = { top = dpi(7), bottom = dpi(7) },
                            bar_color = beautiful.bg_urg,
                            handle_color = beautiful.bg_alt,
                            handle_border_color = beautiful.ac,
                            handle_shape = shapes.circle(9),
                            bar_shape = shapes.rbar(),
                        },
                    },
                    {
                        id = "speaker-value",
                        widget = wibox.widget.textbox,
                        align = "center",
                    },
                },
                -- Microphone Slider
                {
                    layout = wibox.layout.fixed.horizontal,
                    fill_space = true,
                    spacing = dpi(20),
                    {
                        id = "microphone-icon",
                        widget = wibox.widget.textbox,
                        align = "center",
                    },
                    {
                        widget = wibox.container.background,
                        forced_width = dpi(310),
                        forced_height = dpi(40),
                        {
                            id = "microphone-slider",
                            widget = wibox.widget.slider,
                            maximum = 100,
                            bar_height = dpi(2),
                            handle_width = dpi(20),
                            handle_border_width = dpi(2),
                            handle_margins = { top = dpi(7), bottom = dpi(7) },
                            bar_color = beautiful.bg_urg,
                            handle_color = beautiful.bg_alt,
                            handle_border_color = beautiful.ac,
                            handle_shape = shapes.circle(9),
                            bar_shape = shapes.rbar(),
                        },
                    },
                    {
                        id = "microphone-value",
                        widget = wibox.widget.textbox,
                        align = "center",
                    },
                },
            },
        },
    })

    -- Speaker (Volume) Logic
    local speaker_icon = ret:get_children_by_id("speaker-icon")[1]
    local speaker_slider = ret:get_children_by_id("speaker-slider")[1]
    local speaker_value = ret:get_children_by_id("speaker-value")[1]

    audio_service:connect_signal("default-sink::volume", function(_, val)
        speaker_slider:set_value(tonumber(val))
        speaker_value:set_markup(val .. "%")
        -- Update icon based on volume level
        local volume = tonumber(val)
        local icon
        if volume > 80 then
            icon = "󰕾"
        elseif volume > 50 then
            icon = "󰖀"
        elseif volume > 10 then
            icon = "󰕿"
        else
            icon = "󰕿"
        end
        speaker_icon:set_markup(icon)
    end)

    audio_service:connect_signal("default-sink::mute", function(_, mute)
        if mute then
            speaker_icon:set_markup("󰖁")
            speaker_slider:set_bar_active_color(beautiful.fg_alt)
            speaker_slider:set_handle_border_color(beautiful.fg_alt)
        else
            local volume = tonumber(speaker_slider.value) or 50
            local icon
            if volume > 80 then
                icon = "󰕾"
            elseif volume > 50 then
                icon = "󰖀"
            elseif volume > 10 then
                icon = "󰕿"
            else
                icon = "󰕿"
            end
            speaker_icon:set_markup(icon)
            speaker_slider:set_bar_active_color(beautiful.ac)
            speaker_slider:set_handle_border_color(beautiful.ac)
        end
    end)

    speaker_slider:connect_signal("property::value", function(_, new_value)
        local rounded_value = math.floor(new_value)
        speaker_value:set_markup(tostring(rounded_value) .. "%")
        audio_service:set_default_sink_volume(rounded_value)
    end)

    speaker_icon:buttons({
        awful.button({}, 1, function()
            audio_service:toggle_default_sink_mute()
            audio_service:get_default_sink_data()
        end),
    })

    -- Microphone Logic
    local microphone_icon = ret:get_children_by_id("microphone-icon")[1]
    local microphone_slider = ret:get_children_by_id("microphone-slider")[1]
    local microphone_value = ret:get_children_by_id("microphone-value")[1]

    audio_service:connect_signal("default-source::volume", function(_, val)
        microphone_slider:set_value(tonumber(val))
        microphone_value:set_markup(val .. "%")
    end)

    audio_service:connect_signal("default-source::mute", function(_, mute)
        if mute then
            microphone_icon:set_markup(text_icons.mic_off)
            microphone_slider:set_bar_active_color(beautiful.fg_alt)
            microphone_slider:set_handle_border_color(beautiful.fg_alt)
        else
            microphone_icon:set_markup(text_icons.mic_on)
            microphone_slider:set_bar_active_color(beautiful.ac)
            microphone_slider:set_handle_border_color(beautiful.ac)
        end
    end)

    microphone_slider:connect_signal("property::value", function(_, new_value)
        local rounded_value = math.floor(new_value)
        microphone_value:set_markup(tostring(rounded_value) .. "%")
        audio_service:set_default_source_volume(rounded_value)
    end)

    microphone_icon:buttons({
        awful.button({}, 1, function()
            audio_service:toggle_default_source_mute()
            audio_service:get_default_source_data()
        end),
    })

    -- Initial setup
    audio_service:get_default_sink_data()
    audio_service:get_default_source_data()

    return ret
end

return setmetatable({
    new = new,
}, {
    __call = new,
})
