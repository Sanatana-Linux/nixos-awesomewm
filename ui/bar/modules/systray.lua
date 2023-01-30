--  _______               __                    
-- |     __|.--.--.-----.|  |_.----.---.-.--.--.
-- |__     ||  |  |__ --||   _|   _|  _  |  |  |
-- |_______||___  |_____||____|__| |___._|___  |
--          |_____|                      |_____|
-- -------------------------------------------------------------------------- --
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
-- -------------------------------------------------------------------------- --
-- TOGGLER

local togglertext = wibox.widget {
  font = beautiful.nerd_font .. " 36",
  text = "󰅁",
  valign = "center",
  align = "center",
  buttons = {
    awful.button({}, 1, function()
      awesome.emit_signal("systray::toggle")
    end)
  },
  widget = wibox.widget.textbox
}

-- -------------------------------------------------------------------------- --
-- TRAY

local systray = wibox.widget {
  {widget = wibox.widget.systray, align = "center", valign = "center"},
  top = dpi(4),
  bottom = dpi(4),
  visible = false,
  left = dpi(4),
  right = dpi(4),
  widget = wibox.container.margin
}

awesome.connect_signal("systray::toggle", function()
  if systray.visible then
    systray.visible = false
    togglertext.text = "󰅁"
  else
    systray.visible = true
    togglertext.text = "󰅂"
  end
end)

utilities.add_hover(systray, beautiful.black, beautiful.bg_normal)

local widget = wibox.widget {
  {
    {systray, togglertext, layout = wibox.layout.fixed.horizontal},
    shape = utilities.mkroundedrect(8),
    bg = beautiful.bg_systray,
    widget = wibox.container.background,
    border_color = beautiful.grey,
    border_width = 0.5
  },
  top = 6,
  bottom = 6,
  left = 6,
  right = 6,

  widget = wibox.container.margin
}

return widget
