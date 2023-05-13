--  _______
-- |   _   |.--.--.--.-----.-----.-----.--------.-----.
-- |       ||  |  |  |  -__|__ --|  _  |        |  -__|
-- |___|___||________|_____|_____|_____|__|__|__|_____|
-- -------------------------------------------------------------------------- --
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require("menubar")
local switcher = require("ui.window-switcher")
-- -------------------------------------------------------------------------- --
--                                  Essential                                 --
-- -------------------------------------------------------------------------- --
--
awful.keyboard.append_global_keybindings(
  {
    awful.key({modkey}, "F1", hotkeys_popup.show_help, {description = "show help", group = "Awesome"}),
    -- -------------------------------------------------------------------------- --
    --
    awful.key({modkey}, "r", awesome.restart, {description = "reload awesome", group = "Awesome"}),
    -- -------------------------------------------------------------------------- --
    --
    awful.key({modkey, "Shift"}, "q", awesome.quit, {description = "quit awesome", group = "Awesome"}),
        -- ------------------------------------------------- --
    -- Tab Between Applications
    awful.key(
        {'Mod1'},
        'Tab',
        function()
            switcher.switch(1, 'Mod1', 'Alt_L', 'Shift', 'Tab')
        end,
        {description = 'Tab Forward Between Applications', group = 'Launcher'}
    ),
    -- ------------------------------------------------- --
    awful.key(
        {'Mod1', 'Shift'},
        'Tab',
        function()
            switcher.switch(-1, 'Mod1', 'Alt_L', 'Shift', 'Tab')
        end,
        {
            description = 'Tab Back Between Applications',
            group = 'Launcher'
        }
    ),
    -- -------------------------------------------------------------------------- --
    --
    awful.key(
      {modkey},
      "Return",
      function()
        utilities.dropdown.toggle(terminal, "left", "top", 0.85, 0.85)
      end,
      {description = "open a terminal", group = "Awesome"}
    ),
    -- -------------------------------------------------------------------------- --
    --
    awful.key(
      {modkey, "Control"},
      "Return",
      function()
        awful.spawn(terminal)
      end,
      {description = "open a terminal", group = "Awesome"}
    ),
    -- -------------------------------------------------------------------------- --
    --
    awful.key(
      {modkey},
      "p",
      function()
        menubar.show()
      end,
      {description = "show the menubar", group = "Awesome"}
    ),
    -- -------------------------------------------------------------------------- --
    --
    awful.key(
      {modkey, "Shift"},
      "Return",
      function()
        awful.spawn("rofi -show drun")
      end,
      {description = "Open rofi", group = "Awesome"}
    ),
    -- -------------------------------------------------------------------------- --
    --                                  Hardware                                  --
    -- -------------------------------------------------------------------------- --
    --
    -- ------------------------------- Brightness ------------------------------- --
    --
    awful.key(
      {},
      "XF86MonBrightnessUp",
      function()
        awful.spawn("brightnessctl s +5%")
      end,
      {description = "increase brightness", group = "Awesome"}
    ),
    -- -------------------------------------------------------------------------- --
    --
    awful.key(
      {},
      "XF86MonBrightnessDown",
      function()
        awful.spawn("brightnessctl s 5%-")
      end,
      {description = "decrease brightness", group = "Awesome"}
    ),
    -- -------------------------------------------------------------------------- --
    --
    -- --------------------------------- Volume --------------------------------- --
    --
    awful.key(
      {},
      "XF86AudioRaiseVolume",
      function()
        awful.spawn("pamixer -i 3")
      end,
      {description = "increase volume", group = "Awesome"}
    ),
    -- -------------------------------------------------------------------------- --
    awful.key(
      {},
      "XF86AudioLowerVolume",
      function()
        awful.spawn("pamixer -d 3")
      end,
      {description = "decrease volume", group = "Awesome"}
    ),
    -- -------------------------------------------------------------------------- --
    awful.key(
      {},
      "XF86AudioMute",
      function()
        awful.spawn("pamixer -t ")
      end,
      {description = "mute volume", group = "Awesome"}
    ),
    -- -------------------------------------------------------------------------- --
    --
    -- ------------------------------ Media Control ----------------------------- --
    --
    awful.key(
      {},
      "XF86AudioPlay",
      function()
        awful.spawn("playerctl play-pause")
      end,
      {description = "toggle playerctl", group = "Awesome"}
    ),
    -- -------------------------------------------------------------------------- --
    --
    awful.key(
      {},
      "XF86AudioPrev",
      function()
        awful.spawn("playerctl previous")
      end,
      {description = "playerctl previous", group = "Awesome"}
    ),
    -- -------------------------------------------------------------------------- --
    --
    awful.key(
      {},
      "XF86AudioNext",
      function()
        awful.spawn("playerctl next")
      end,
      {description = "playerctl next", group = "Awesome"}
    )
    -- -------------------------------------------------------------------------- --
    --
  }
)
