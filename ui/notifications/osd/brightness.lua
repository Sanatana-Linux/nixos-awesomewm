local osd = require("ui.notifications.osd")

awesome.connect_signal("signal::brightness", function(value)
  local icon = icons.brightness

  if value ~= 0 then
    osd.osd_bar.color = beautiful.fg_normal
  else
    local bri_icon = gears.color.recolor_image(icon, beautiful.lessgrey)
    icon = bri_icon
  end

  osd.osd_bar.value = value
  osd.osd_icon.icon.image = icon
  osd.toggle_osd()
end)
