local wibox = require("wibox")
local helpers = require("helpers")
local beautiful = require("beautiful")
local awful = require("awful")

local icon = wibox.widget.textbox()

icon.font = beautiful.nerd_font .. " 19"
icon.markup = utilities.get_colorized_markup("⏻", beautiful.lesswhite)

local button = wibox.widget {
  {
    icon,
    top = 4,
    bottom = 4,
    left = 8,
    right = 8,
    widget = wibox.container.margin
  },
  bg = beautiful.black,
  shape = utilities.mkroundedrect(),
  border_color = beautiful.grey,
  border_width = 0.5,
  widget = wibox.container.background
}

utilities.add_hover(button, beautiful.black, beautiful.bg_normal)

button:add_button(awful.button({}, 1, function()
  require"naughty".notify {title = "needs to be implemented"}
end))

return wibox.widget {
  button,
  top = 6,
  bottom = 6,
  widget = wibox.container.margin
}
