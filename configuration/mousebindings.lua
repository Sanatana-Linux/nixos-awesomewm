--  _______
-- |   |   |.-----.--.--.-----.-----.
-- |       ||  _  |  |  |__ --|  -__|
-- |__|_|__||_____|_____|_____|_____|
--  ______ __           __ __
-- |   __ \__|.-----.--|  |__|.-----.-----.
-- |   __ <  ||     |  _  |  ||     |  _  |
-- |______/__||__|__|_____|__||__|__|___  |
--                                  |_____|
-- ----------------------------------------------------------- --

local menu = require("ui.menu")

local function set_mousebindings()
  awful.mouse.append_global_mousebindings({
    awful.button({}, 3, function()
      awful.menu.new()
    end),
  })

  client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
      awful.button({}, 1, function(c)
        c:activate({ context = "mouse_click" })
      end),
      awful.button({ modkey }, 1, function(c)
        c:activate({ context = "mouse_click", action = "mouse_move" })
      end),
      awful.button({ modkey }, 3, function(c)
        c:activate({ context = "mouse_click", action = "mouse_resize" })
      end),
    })
  end)
end

set_mousebindings()
