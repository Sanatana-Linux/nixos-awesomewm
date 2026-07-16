---@diagnostic disable: undefined-global
local awful = require("awful")
local gears = require("gears")
local glib = require("lgi").GLib
local audio_service_module = require("service.audio")
local audio_service = audio_service_module.get_default()
local volume_osd = require("ui.popups.on_screen_display.volume").get_default()
local brightness_service_module = require("service.brightness")
local brightness_service = brightness_service_module.get_default()
local brightness_osd =
    require("ui.popups.on_screen_display.brightness").get_default()
local screenshot_popup = require("ui.popups.screenshot_popup").get_default()
local modkey = "Mod4"

-- Volume control throttle — shared across all volume key handlers
-- Prevents double-fire from duplicate keysym+keycode bindings
-- Uses GLib monotonic time (microseconds) — NOT os.clock() which is CPU time
local volume_tick = 0

---@param rel string "+5" or "-5"
local function handle_volume_change(rel)
    local now = glib.get_monotonic_time()
    if now - volume_tick < 80000 then
        return
    end -- ~80ms throttle
    volume_tick = now

    if audio_service and audio_service.set_default_sink_volume then
        audio_service:set_default_sink_volume(rel, function(volume, is_muted)
            volume_osd:show(volume, is_muted)
        end)
    end
end

local function handle_volume_mute()
    if audio_service and audio_service.toggle_default_sink_mute then
        audio_service:toggle_default_sink_mute(function(volume, is_muted)
            volume_osd:show(volume, is_muted)
        end)
    end
end

awful.keyboard.append_global_keybindings({

    -- -------------------------------------------------------------------------- --
    -- Volume — keysym-based (for systems with XF86Audio* keysym mapping)
    awful.key({}, "XF86AudioRaiseVolume", function()
        handle_volume_change("+5")
    end, { description = "increase volume", group = "Hardware" }),

    awful.key({}, "XF86AudioLowerVolume", function()
        handle_volume_change("-5")
    end, { description = "decrease volume", group = "Hardware" }),

    awful.key({}, "XF86AudioMute", function()
        handle_volume_mute()
    end, { description = "toggle mute", group = "Hardware" }),

    -- Show volume OSD (Mod4+Ctrl+S)
    -- Shows current volume level without changing it
    awful.key({ modkey, "Control" }, "s", function()
        volume_osd:show(
            audio_service.default_sink_volume or 0,
            audio_service.default_sink_mute or false
        )
    end, { description = "show current volume", group = "Hardware" }),

    -- Volume — keycode-based fallback (catches events when xkb keysym
    -- translation is missing or intercepted, e.g. by keyd)
    -- #123 = KEY_VOLUMEUP,   #122 = KEY_VOLUMEDOWN,   #121 = KEY_MUTE
    awful.key({}, "#123", function()
        handle_volume_change("+5")
    end, { description = "increase volume (keycode)", group = "Hardware" }),

    awful.key({}, "#122", function()
        handle_volume_change("-5")
    end, { description = "decrease volume (keycode)", group = "Hardware" }),

    awful.key({}, "#121", function()
        handle_volume_mute()
    end, { description = "toggle mute (keycode)", group = "Hardware" }),

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
