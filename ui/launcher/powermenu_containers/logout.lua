--   +---------------------------------------------------------------+
local function do_notify()
  local confirm = naughty.action({ name = "Confirm" })
  local cancel = naughty.action({ name = "Cancel" })
  --   +---------------------------------------------------------------+
  -- copy to clipboard button
  confirm:connect_signal("invoked", function()
    awful.spawn("doas systemctl restart display-manager")
  end)
  --   +---------------------------------------------------------------+
  -- delete
  cancel:connect_signal("invoked", function()
    return
  end)
  --   +---------------------------------------------------------------+
  -- Show the notification.
  naughty.notify({
    app_name = "Confirmation",
    app_icon = icons.power,
    position = "top_middle",
    ontop = true,
    icon = icons.logout,
    title = "Please Confirm You Want to Log Out",
    text = "Please Confirm You Would Like to Log Out by Pressing Confirm Below",
    actions = { confirm, cancel },
  })
end
--   +---------------------------------------------------------------+
-- log out button
Logout = utilities.interaction.mkbtn({
  {
    {
      widget = wibox.widget.imagebox,
      image = icons.logout,
      resize = true,
      opacity = 1,
    },
    valign = "center",
    halign = "center",
    layout = wibox.container.place,
  },

  shape = utilities.graphics.mkroundedrect(),
  widget = wibox.container.background,
  forced_height = dpi(48),
  forced_width = dpi(48),
}, beautiful.widget_back, beautiful.widget_back_focus)
Logout:connect_signal("button::press", function()
  do_notify()
end)
return Logout
