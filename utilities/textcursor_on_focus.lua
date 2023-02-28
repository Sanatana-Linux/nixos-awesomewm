local gears	= require("gears")
local cairo = require("lgi").cairo

local last_wibox

return function (widget, wibox)
  if wibox then
    widget:connect_signal("mouse::enter", function()
        wibox.cursor = "xterm"
    end)
    widget:connect_signal("mouse::leave", function()
      wibox.cursor = "left_ptr"
    end)
  else
      widget:connect_signal("mouse::enter", function()
          last_wibox = mouse.current_wibox
          last_wibox.cursor = "xterm"
      end)
      widget:connect_signal("mouse::leave", function()
          last_wibox.cursor = "left_ptr"
      end)
  end
  return widget
end