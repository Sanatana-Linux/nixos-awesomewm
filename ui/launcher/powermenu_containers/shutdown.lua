local function do_notify()
  local confirm = naughty.action({ name = "Confirm" })
  local cancel = naughty.action({ name = "Cancel" })
  -- -------------------------------------------------------------------------- --
  -- copy to clipboard button
  confirm:connect_signal("invoked", function()
    awful.spawn("doas  shutdown -n now")
  end)
  -- -------------------------------------------------------------------------- --
  -- delete
  cancel:connect_signal("invoked", function()
    return
  end)
  -- -------------------------------------------------------------------------- --
  -- Show the notification.
  naughty.notify({
    app_name = "Confirmation",
    app_icon = icons.power,
    position = "top_middle",
    ontop = true,
    icon = icons.power,
    title = "Please Confirm You Want to Shut Down",
    text = "Please Confirm You Would Like to Shut Down by Pressing Confirm Below",
    actions = { confirm, cancel },
  })
end

Shutdown = utilities.interaction.mkbtn({
  {
    {
      widget = wibox.widget.imagebox,
      image = icons.power,
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
Shutdown:connect_signal("button::press", function()
  do_notify()
end)
return Shutdown
