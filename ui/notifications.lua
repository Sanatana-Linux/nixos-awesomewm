local naughty = require "naughty"
local beautiful = require 'beautiful'

local dpi = beautiful.xresources.apply_dpi

-- display errors
naughty.connect_signal('request::display_error', function (message, startup)
    naughty.notification {
        urgency = 'critical',
        title = 'An error happened' .. (startup and ' during startup' or ''),
        message = message,
    }
end)

-- display notification
naughty.connect_signal('request::display', function (n)
naughty.layout.box {
  notification = n,
  position = 'bottom_right',
  border_width = 1,
  border_color = beautiful.grey, 
  bg = beautiful.black,
  fg = beautiful.lesswhite,
  shape = utilities.mkroundedrect(10),
  minimum_width = dpi(240),
  widget_template = utilities.get_notification_widget(n)
}
end)
