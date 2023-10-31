--  _______
-- |   _   |.--.--.--.-----.-----.-----.--------.-----.
-- |       ||  |  |  |  -__|__ --|  _  |        |  -__|
-- |___|___||________|_____|_____|_____|__|__|__|_____|
-- -------------------------------------------------------------------------- --
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require("menubar")
local launcher = require("ui.launcher")

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

  --       ┏╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┓
  --       ╏                                                               ╏
  --       ╏                         Hardware Keys                         ╏
  --       ╏                                                               ╏
  --       ┗╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┛

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
  -- ------------------------------- Brightness ------------------------------- --
  awful.key({}, "XF86MonBrightnessUp", function()
    awful.spawn("doas light -A 5%", false)
    awful.spawn.with_line_callback("doas light -G", {
      stdout = function(value)
        awful.spawn.with_line_callback("doas light -M ", {
          stdout = function(max)
            percentage = value / max * 100
            -- if percentage ~= percentage_old then
            awesome.emit_signal("signal::brightness", percentage)
            -- percentage_old = percentage
            -- end
          end,
        })
      end,
    })
  end, { description = "Increase Brightness", group = "Awesome" }),
  --   +---------------------------------------------------------------+
  awful.key({}, "XF86MonBrightnessDown", function()
    awful.spawn("doas light -U 5%", false)
    awful.spawn.with_line_callback("doas light -G", {
      stdout = function(value)
        awful.spawn.with_line_callback("doas light -M ", {
          stdout = function(max)
            percentage = value / max * 100
            -- if percentage ~= percentage_old then
            awesome.emit_signal("signal::brightness", percentage)
            -- percentage_old = percentage
            -- end
          end,
        })
      end,
    })
  end, { description = "Decrease Brightness", group = "Awesome" }),
  -- -------------------------- Volume ---------------------------------------- --
  awful.key({}, "XF86AudioRaiseVolume", function()
    awful.spawn.easy_async_with_shell("pamixer -i 5", function()
      awful.spawn.with_line_callback("pamixer --get-volume", {
        stdout = function(value)
          awesome.emit_signal("signal::volume", value, nil)
        end,
      })
    end)
  end, { description = "Increase Volume", group = "Awesome" }),
  --   +---------------------------------------------------------------+
  awful.key({}, "XF86AudioLowerVolume", function()
    awful.spawn.easy_async_with_shell("pamixer -d 5", function()
      awful.spawn.with_line_callback("pamixer --get-volume", {
        stdout = function(value)
          awesome.emit_signal("signal::volume", value, nil)
        end,
      })
    end)
  end, { description = "Decrease Volume", group = "Awesome" }),
  --   +---------------------------------------------------------------+
  awful.key({}, "XF86AudioMute", function()
    awful.spawn("pamixer -t")
    awful.spawn.easy_async_with_shell("pamixer --get-mute", function(value)
      awesome.emit_signal("signal::volume:muted", value)
    end)
  end, { description = "Mute Volume", group = "Awesome" }),
})
