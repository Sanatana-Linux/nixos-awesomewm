-- core/keybind/hardware_functions.lua
-- This module defines keybindings for hardware-related functions,
-- such as volume control, screenshot, and power management.
-- Brightness control keybindings have been added, linking to the
-- new brightness service.

local awful = require("awful") -- AwesomeWM utility library
local gears = require("gears") -- AwesomeWM gears for timers
local audio_service_module = require("service.audio") -- Import audio service module
local audio_service = audio_service_module.get_default() -- Get default audio service instance
local volume_osd = require("ui.popups.on_screen_display.volume").get_default() -- Import volume OSD
local brightness_service_module = require("service.brightness") -- Import brightness service module
local brightness_service = brightness_service_module.get_default() -- Get default brightness service instance
local brightness_osd = require("ui.popups.on_screen_display.brightness").get_default() -- Import brightness OSD
local screenshot_popup = require("ui.popups.screenshot_popup").get_default() -- Screenshot popup instance
local powermenu = require("ui.popups.powermenu").get_default() -- Power menu UI instance
-- modkey is defined globally in core/keybind/init.lua
local modkey = "Mod4" -- Set modkey (usually the Super/Windows key)

-- Volume control throttling
local volume_throttle_timer = nil
local volume_throttle_delay = 0.1 -- 100ms delay between volume adjustments

awful.keyboard.append_global_keybindings({
    -- -------------------------------------------------------------------------- --
    -- Volume keybindings
    awful.key({}, "XF86AudioRaiseVolume", function()
        if volume_throttle_timer and volume_throttle_timer.started then
            return -- Ignore if throttle timer is active
        end
        
        if audio_service and audio_service.set_default_sink_volume then
            audio_service:set_default_sink_volume("+5", function(volume, is_muted)
                volume_osd:show(volume, is_muted)
            end)
            
            -- Start throttle timer
            volume_throttle_timer = gears.timer({
                timeout = volume_throttle_delay,
                single_shot = true,
                callback = function() end
            })
            volume_throttle_timer:start()
        end
    end, { description = "increase volume", group = "hardware" }),
    awful.key({}, "XF86AudioLowerVolume", function()
        if volume_throttle_timer and volume_throttle_timer.started then
            return -- Ignore if throttle timer is active
        end
        
        if audio_service and audio_service.set_default_sink_volume then
            audio_service:set_default_sink_volume("-5", function(volume, is_muted)
                volume_osd:show(volume, is_muted)
            end)
            
            -- Start throttle timer
            volume_throttle_timer = gears.timer({
                timeout = volume_throttle_delay,
                single_shot = true,
                callback = function() end
            })
            volume_throttle_timer:start()
        end
    end, { description = "decrease volume", group = "hardware" }),
    awful.key({}, "XF86AudioMute", function()
        if audio_service and audio_service.toggle_default_sink_mute then
            audio_service:toggle_default_sink_mute(function(volume, is_muted)
                volume_osd:show(volume, is_muted)
            end)
        end
    end, { description = "toggle mute", group = "hardware" }),

    -- -------------------------------------------------------------------------- --
    -- Brightness control keybindings
    awful.key({}, "XF86MonBrightnessUp", function()
        if brightness_service and brightness_service.increase then
            brightness_service:increase(function(value)
                brightness_osd:show(value)
            end)
        end
    end, { description = "increase brightness", group = "hardware" }),

    awful.key({}, "XF86MonBrightnessDown", function()
        if brightness_service and brightness_service.decrease then
            brightness_service:decrease(function(value)
                brightness_osd:show(value)
            end)
        end
    end, { description = "decrease brightness", group = "hardware" }),

    -- -------------------------------------------------------------------------- --
    -- Power Menu keybinding
    awful.key({ modkey }, "x", function()
        powermenu:show() -- Show the power menu UI
    end, { description = "show power menu", group = "awesome" }),

    -- -------------------------------------------------------------------------- --
    -- Lockscreen keybinding
    awful.key({ modkey, "Control" }, "l", function()
        awful.spawn("/home/tlh/.config/awesome/bin/glitchlock.sh")
    end, { description = "lock screen", group = "awesome" }),

    -- -------------------------------------------------------------------------- --
    -- Screenshot keybindings
    awful.key({ modkey }, "Print", function()
        screenshot_popup:toggle()
    end, { description = "show screenshot menu", group = "utility" }),
})
