local wibox = require("wibox")
local mkroundedrect = require("utilities.mkroundedcontainer")
local beautiful = require("beautiful")
return function(spacing, widget)
  if not widget then
    widget = wibox.widget.textbox()
    widget.markup = "Hello, World!"
    widget.valign = "center"
    widget.align = "center"
  end

  return wibox.widget {
    {widget, margins = spacing, widget = wibox.container.margin},
    bg = beautiful.bg_lighter,
    shape = utilities.mkroundedrect(),
    border_color = beautiful.grey,
    border_width = 0.75,
    widget = wibox.container.background
  }
end
