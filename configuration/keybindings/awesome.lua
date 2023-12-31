--  _______
-- |   _   |.--.--.--.-----.-----.-----.--------.-----.
-- |       ||  |  |  |  -__|__ --|  _  |        |  -__|
-- |___|___||________|_____|_____|_____|__|__|__|_____|
-- -------------------------------------------------------------------------- --
local hotkeys_popup = require("awful.hotkeys_popup").widget
local menubar = require("menubar")
local launcher = require("ui.launcher")

--       ┏╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┓
--       ╏                                                                                                                                                    ╏
--       ╏                          Essential                                                                                                        ╏
--       ╏                                                                                                                                                    ╏
--       ┗╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┛

awful.keyboard.append_global_keybindings({
  awful.key(
    { modkey },
    "F1",
    hotkeys_popup.show_help,
    { description = "Show Help", group = "Awesome" }
  ),
  --   +---------------------------------------------------------------+
  awful.key(
    { modkey },
    "r",
    awesome.restart,
    { description = "Reload Awesome", group = "Awesome" }
  ),
  --+---------------------------------------------------------------+
  awful.key(
    { modkey, "Shift" },
    "q",
    awesome.quit,
    { description = "Quit Awesome", group = "Awesome" }
  ),
  --   +---------------------------------------------------------------+
  -- Client Selection Menu
  awful.key({ modkey }, "Tab", function()
    awful.menu.menu_keys.down = { "Down", "Alt_L" }
    awful.menu.menu_keys.up = { "Up", "Alt_R" }
    awful.menu.clients(
      { theme = { width = 450, bg = beautiful.bg_normal .. "66" } },
      { keygrabber = true }
    )
  end, { description = "Client Selection Menu", group = "Awesome" }),
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
    modules.dropdown.toggle(terminal, "left", "top", 0.75, 0.75)
  end, { description = "Open a dropdown terminal", group = "Awesome" }),
  --   +---------------------------------------------------------------+
  awful.key({ modkey, "Control" }, "Return", function()
    awful.spawn(terminal)
  end, { description = "Open a terminal", group = "Awesome" }),
  --+---------------------------------------------------------------+
  awful.key({ modkey }, "p", function()
    menubar.show()
  end, { description = "Show the menubar", group = "Awesome" }),
  --+---------------------------------------------------------------+
  awful.key({ modkey, "Shift" }, "Return", function()
    awesome.emit_signal("toggle::launcher")
  end, { description = "Open application launcher", group = "Awesome" }),

  --  ┏╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┓
  --  ╏                                                                                                                                                    ╏
  --  ╏   Function Keys                                                                                                                      ╏
  --  ╏                                                                                                                                                    ╏
  --  ┗╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┛

  -- Media Controls
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

  -- Brightness Keys
  awful.key({}, "XF86MonBrightnessUp", function()
    awful.spawn.easy_async_with_shell("brightnessctl set +5%", nil)
  end, { description = "Increase Brightness", group = "Awesome" }),

  --   +---------------------------------------------------------------+

  awful.key({}, "XF86MonBrightnessDown", function()
    awful.spawn.easy_async_with_shell("brightnessctl set 5%-", nil)
  end, { description = "Decrease Brightness", group = "Awesome" }),

  --   +---------------------------------------------------------------+

  -- Volume Keys
  awful.key({}, "XF86AudioRaiseVolume", function()
    awful.spawn.easy_async_with_shell("pamixer --get-volume", function(stdout)
      local currentVolume = tonumber(stdout)
      newVolume = currentVolume + 5
      awful.spawn.easy_async_with_shell("pamixer --set-volume " .. newVolume)
      return newVolume
    end)
    awesome.emit_signal("signal::volume", newVolume, nil)
  end, { description = "Increase Volume", group = "Awesome" }),

  --   +---------------------------------------------------------------+

  awful.key({}, "XF86AudioLowerVolume", function()
    awful.spawn.easy_async_with_shell("pamixer --get-volume", function(stdout)
      local currentVolume = tonumber(stdout)
      newVolume = currentVolume - 5
      awful.spawn.easy_async_with_shell("pamixer --set-volume " .. newVolume)
      return newVolume
    end)
    awesome.emit_signal("signal::volume", newVolume, nil)
  end, { description = "Decrease Volume", group = "Awesome" }),

  --   +---------------------------------------------------------------+

  awful.key({}, "XF86AudioMute", function()
    local muted = nil
    awful.spawn.easy_async_with_shell("pamixer --get-mute", function(stdout)
      muted = stdout
      if muted == false then
        awful.spawn.easy_async_with_shell("pamixer --set-mute " .. newVolume)
        muted = true
      end
      return muted
    end)
    awesome.emit_signal("signal::volume", nil, muted)
  end, { description = "Mute Volume", group = "Awesome" }),
})
