--                                 __     __     __
--                      .--------.|  |--.|  |--.|  |_.-----.
--                      |        ||    < |  _  ||   _|     |
--                      |__|__|__||__|__||_____||____|__|__|
--
--   +---------------------------------------------------------------+
-- Makes a button stylized the right way for the configuration
-- @param template variable the widget that is being triggered by the button
-- @param bg variable/string color for the background normally
-- @param hbg variable/string color for the widget when it is hovered
-- @rtadius string/variable the border radius for the button
-- @return button object
local wibox = require("wibox")
local beautiful = require("beautiful")
local mkroundedrect = require("utilities.widgets.mkroundedrect")
local add_hover = require("utilities.widgets.add_hover")
local dpi = beautiful.xresources.apply_dpi

return function(template, bg, hbg, radius)
  local button = wibox.widget({
    {
      template,
      margins = dpi(5),
      widget = wibox.container.margin,
    },
    bg = bg,
    widget = wibox.container.background,
    shape = mkroundedrect(radius),
    border_width = dpi(1),
    border_color = beautiful.grey,
  })

  if bg and hbg then
    add_hover(button, bg, hbg)
  end

  return button
end
