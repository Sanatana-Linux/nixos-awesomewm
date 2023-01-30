local mkroundedrect = require("utilities.mkroundedrect")
local wibox = require("wibox")

-- make a rounded container for make work the antialiasing.
return function(template, bg)
  return wibox.widget {
    template,
    shape = mkroundedrect(),
    bg = bg,
    widget = wibox.container.background
  }
end
