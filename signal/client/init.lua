require("awful.autofocus")

client.connect_signal("request::manage", function(c)
  if c.floating then
    awful.placement.centered(c, {
      honor_workarea = true,
      honor_padding = true,
      margins = beautiful.useless_gap * 2,
      shape = utilities.graphics.mkroundedrect(),
    })
  end
end)

client.connect_signal("mouse::enter", function(c)
  c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)
