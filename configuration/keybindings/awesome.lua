--  _______
-- |   _   |.--.--.--.-----.-----.-----.--------.-----.
-- |       ||  |  |  |  -__|__ --|  _  |        |  -__|
-- |___|___||________|_____|_____|_____|__|__|__|_____|
-- -------------------------------------------------------------------------- --
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require("menubar")
local launcher = require("widgets.launcher")

--       ┏╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┓
--       ╏                                                               ╏
--       ╏                          Essential                            ╏
--       ╏                                                               ╏
--       ┗╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┛

awful.keyboard.append_global_keybindings({
    awful.key(
        { modkey },
        "F1",
        hotkeys_popup.show_help,
        { description = "show help", group = "Awesome" }
    ),
    --   +---------------------------------------------------------------+
    awful.key(
        { modkey },
        "r",
        awesome.restart,
        { description = "reload awesome", group = "Awesome" }
    ),
    --+---------------------------------------------------------------+
    awful.key(
        { modkey, "Shift" },
        "q",
        awesome.quit,
        { description = "quit awesome", group = "Awesome" }
    ),
    --   +---------------------------------------------------------------+
    -- Tab Between Applications
    awful.keygrabber({
        keybindings = {
            awful.key({
                modifiers = { "Mod1" },
                key = "Tab",
                on_press = function()
                    awesome.emit_signal("window_switcher::next")
                end,
            }),
        },
        root_keybindings = {
            awful.key({
                modifiers = { "Mod1" },
                key = "Tab",
                on_press = function() end,
            }),
        },
        stop_key = "Mod1",
        stop_event = "release",
        start_callback = function()
            awesome.emit_signal("window_switcher::toggle")
        end,
        stop_callback = function()
            awesome.emit_signal("window_switcher::raise")
            awesome.emit_signal("window_switcher::toggle")
        end,
        export_keybindings = true,
    }),

    --   +---------------------------------------------------------------+
    awful.key({ modkey }, "Return", function()
        modules.dropdown.toggle(terminal, "left", "top", 0.85, 0.85)
    end, { description = "open a dropdown terminal", group = "Awesome" }),
    --   +---------------------------------------------------------------+
    awful.key({ modkey, "Control" }, "Return", function()
        awful.spawn(terminal)
    end, { description = "open a terminal", group = "Awesome" }),
    --+---------------------------------------------------------------+
    awful.key({ modkey }, "p", function()
        menubar.show()
    end, { description = "show the menubar", group = "Awesome" }),
    --+---------------------------------------------------------------+
    awful.key({ modkey, "Shift" }, "Return", function()
        awesome.emit_signal("toggle::launcher")
        if launcher.launcherdisplay.visible == true then
            awful.keyboard.emulate_key_combination({}, "Escape")
        end
    end, { description = "Open application launcher", group = "Awesome" }),

    --       ┏╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┓
    --       ╏                                                               ╏
    --       ╏                         Hardware Keys                         ╏
    --       ╏                                                               ╏
    --       ┗╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┛

    -- ------------------------------- Brightness ------------------------------- --
    awful.key({}, "XF86MonBrightnessUp", function()
        awful.spawn("brightnessctl s +5%")
        awful.spawn("brightnessctl get", function(brightness)
            awful.emit_signal("signal::brightness", brightness)
        end)
    end, { description = "increase brightness", group = "Awesome" }),
    --+---------------------------------------------------------------+
    awful.key({}, "XF86MonBrightnessDown", function()
        awful.spawn("brightnessctl s 5%-")
        awful.spawn("brightnessctl get", function(brightness)
            awful.emit_signal("signal::brightness", brightness)
        end)
    end, { description = "decrease brightness", group = "Awesome" }),
    -- ------------------------------- Volume  ------------------------------- --
    awful.key({}, "XF86AudioRaiseVolume", function()
        awful.spawn("pamixer --get-volume", function(value)
            value = value + 5
            awful.spawn("pamixer --set-volume " .. value)
            awesome.emit_signal("signal::volume", value)
        end)
    end, { description = "increase volume", group = "Awesome" }),
    --+---------------------------------------------------------------+
    awful.key({}, "XF86AudioLowerVolume", function()
        awful.spawn("pamixer --get-volume", function(value)
            value = value - 5
            awful.spawn("pamixer --set-volume " .. value)
            awesome.emit_signal("signal::volume", value)
        end)
    end, { description = "decrease volume", group = "Awesome" }),
    --   +---------------------------------------------------------------+
    awful.key({}, "XF86AudioMute", function()
        awful.spawn("pamixer --toggle-mute ")
        awful.spawn("pamixer --get-mute", function(mute)
            awesome.emit_signal("signal::volume", nil, mute)
        end)
    end, { description = "mute volume", group = "Awesome" }),
    -- ------------------------------ Media Control ----------------------------- --
    --
    awful.key({}, "XF86AudioPlay", function()
        awful.spawn("playerctl play-pause")
    end, { description = "toggle playerctl", group = "Awesome" }),
    --+---------------------------------------------------------------+
    awful.key({}, "XF86AudioPrev", function()
        awful.spawn("playerctl previous")
    end, { description = "playerctl previous", group = "Awesome" }),
    --   +---------------------------------------------------------------+
    awful.key({}, "XF86AudioNext", function()
        awful.spawn("playerctl next")
    end, { description = "playerctl next", group = "Awesome" }),
    --   +---------------------------------------------------------------+
})
