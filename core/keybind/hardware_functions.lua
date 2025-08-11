-- core/keybind/hardware_functions.lua
-- This module defines keybindings for hardware-related functions,
-- such as volume control, screenshot, and power management.
-- Brightness control keybindings have been added, linking to the
-- new brightness service.

local awful = require("awful") -- AwesomeWM utility library
local audio_service_module = require("service.audio") -- Import audio service module
local audio_service = audio_service_module.get_default() -- Get default audio service instance
local volume_osd = require("ui.popups.on_screen_display.volume").get_default() -- Import volume OSD
local brightness_service_module = require("service.brightness") -- Import brightness service module
local brightness_service = brightness_service_module.get_default() -- Get default brightness service instance
local brightness_osd = require("ui.popups.on_screen_display.brightness").get_default() -- Import brightness OSD
local screenshot = require("service.screenshot").get_default() -- Screenshot service instance
local powermenu = require("ui.popups.powermenu").get_default() -- Power menu UI instance
-- modkey is defined globally in core/keybind/init.lua
local modkey = "Mod4" -- Set modkey (usually the Super/Windows key)

awful.keyboard.append_global_keybindings({
    -- -------------------------------------------------------------------------- --
    -- Volume keybindings
    awful.key({}, "XF86AudioRaiseVolume", function()
        if audio_service and audio_service.set_default_sink_volume then
            audio_service:set_default_sink_volume("+5", function(volume, is_muted)
                volume_osd:show(volume, is_muted)
            end)
        end
    end, { description = "increase volume", group = "hardware" }),
    awful.key({}, "XF86AudioLowerVolume", function()
        if audio_service and audio_service.set_default_sink_volume then
            audio_service:set_default_sink_volume("-5", function(volume, is_muted)
                volume_osd:show(volume, is_muted)
            end)
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
    -- Screenshot keybindings (handled by screenshot service)
    awful.key({ modkey }, "Print", function()
        screenshot:take_select() -- Take a screenshot of a selected area
    end, { description = "take screenshot (select area)", group = "utility" }),

    -- Take a full screenshot
    awful.key({}, "Print", function()
        screenshot:take_full()
    end, { description = "take full screenshot", group = "utility" }),

    -- Take a delayed screenshot (3 seconds)
    awful.key({ "Shift" }, "Print", function()
        screenshot:take_delay(3)
    end, { description = "take screenshot with delay", group = "utility" }),
})
