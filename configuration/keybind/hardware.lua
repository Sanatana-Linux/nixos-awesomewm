---@diagnostic disable: undefined-global
local awful = require("awful")
local gears = require("gears")
local audio_service_module = require("service.audio")
local audio_service = audio_service_module.get_default()
local volume_osd = require("ui.popups.on_screen_display.volume").get_default()
local brightness_service_module = require("service.brightness")
local brightness_service = brightness_service_module.get_default()
local brightness_osd =
    require("ui.popups.on_screen_display.brightness").get_default()
local screenshot_popup = require("ui.popups.screenshot_popup").get_default()
local modkey = "Mod4"

-- Volume control throttling
local volume_throttle_timer = nil
local volume_throttle_delay = 0.1

awful.keyboard.append_global_keybindings({

    -- -------------------------------------------------------------------------- --
    -- Volume
    awful.key({}, "XF86AudioRaiseVolume", function()
        if volume_throttle_timer and volume_throttle_timer.started then
            return
        end
        if audio_service and audio_service.set_default_sink_volume then
            audio_service:set_default_sink_volume(
                "+5",
                function(volume, is_muted)
                    volume_osd:show(volume, is_muted)
                end
            )
            volume_throttle_timer = gears.timer({
                timeout = volume_throttle_delay,
                single_shot = true,
                callback = function() end,
            })
            volume_throttle_timer:start()
        end
    end, { description = "increase volume", group = "Hardware" }),

    awful.key({}, "XF86AudioLowerVolume", function()
        if volume_throttle_timer and volume_throttle_timer.started then
            return
        end
        if audio_service and audio_service.set_default_sink_volume then
            audio_service:set_default_sink_volume(
                "-5",
                function(volume, is_muted)
                    volume_osd:show(volume, is_muted)
                end
            )
            volume_throttle_timer = gears.timer({
                timeout = volume_throttle_delay,
                single_shot = true,
                callback = function() end,
            })
            volume_throttle_timer:start()
        end
    end, { description = "decrease volume", group = "Hardware" }),

    awful.key({}, "XF86AudioMute", function()
        if audio_service and audio_service.toggle_default_sink_mute then
            audio_service:toggle_default_sink_mute(function(volume, is_muted)
                volume_osd:show(volume, is_muted)
            end)
        end
    end, { description = "toggle mute", group = "Hardware" }),

    -- -------------------------------------------------------------------------- --
    -- Brightness
    awful.key({}, "XF86MonBrightnessUp", function()
        if brightness_service and brightness_service.increase then
            brightness_service:increase(function(value)
                brightness_osd:show(value)
            end)
        end
    end, { description = "increase brightness", group = "Hardware" }),

    awful.key({}, "XF86MonBrightnessDown", function()
        if brightness_service and brightness_service.decrease then
            brightness_service:decrease(function(value)
                brightness_osd:show(value)
            end)
        end
    end, { description = "decrease brightness", group = "Hardware" }),

    -- -------------------------------------------------------------------------- --
    -- Lock Screen
    awful.key({ modkey, "Control" }, "l", function()
        awesome.emit_signal("lockscreen::visible", true)
    end, { description = "lock screen", group = "Hardware" }),

    -- -------------------------------------------------------------------------- --
    -- Screenshot
    awful.key({ modkey }, "Print", function()
        screenshot_popup:toggle()
    end, { description = "show screenshot menu", group = "Hardware" }),
})
