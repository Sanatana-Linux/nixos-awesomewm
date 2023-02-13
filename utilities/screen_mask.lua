local awful = require("awful")
local wibox = require("wibox")


return function(s, bg)
  local mask = wibox({
    visible = false,
    ontop = true,
    type = "splash",
    screen = s
  })
  awful.placement.maximize(mask)
  mask.bg = bg
  return mask
end
