local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local awful = require("awful")

local icon = wibox.widget {
  markup = "",
  font = beautiful.nerd_font .. " 19",
  widget = wibox.widget.textbox,
}

local button = wibox.widget {
  {
    icon,
    top = 4,
    bottom = 4,
    left = 8,
    right = 8,
    widget = wibox.container.margin,
  },
  shape = utilities.mkroundedrect(),
  bg = beautiful.black,
  border_width=0.5,
  border_color=beautiful.grey,
  widget = wibox.container.background,
}

utilities.add_hover(button, beautiful.black, beautiful.bg_normal)

button:add_button(awful.button({}, 1, function ()
  awesome.emit_signal("dashboard::toggle")
end))

return wibox.widget {
  button,
  top = 6,
  bottom = 6,
  widget = wibox.container.margin,
}
