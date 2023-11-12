local osd = wibox({
  type = "notification",
  height = dpi(200),
  width = dpi(200),
  shape = utilities.widgets.mkroundedrect(),
  bg = "#00000000",
  ontop = true,
  visible = false,
})

osd.osd_icon = wibox.widget({
  {
    id = "icon",
    resize = true,
    widget = wibox.widget.imagebox,
    forced_height = dpi(72),
    forced_width = dpi(72),
    valign = "center",
  },
  top = dpi(35),
  left = dpi(65),
  right = dpi(65),
  bottom = dpi(35),
  widget = wibox.container.margin,
})

osd.osd_bar = wibox.widget({
  max_value = 100,
  value = 0,
  background_color = beautiful.bg_normal,
  color = beautiful.fg_normal,
  shape = gears.shape.rounded_bar,
  bar_shape = gears.shape.rounded_bar,
  forced_height = dpi(24),
  widget = wibox.widget.progressbar,
})

osd:setup({
  {
    {
      {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        nil,
        osd.osd_icon,
        nil,
      },
      layout = wibox.layout.fixed.vertical,
    },
    {
      osd.osd_bar,
      left = dpi(24),
      right = dpi(24),
      bottom = dpi(24),
      widget = wibox.container.margin,
    },
    layout = wibox.layout.align.vertical,
  },
  bg = beautiful.bg_normal .. "88",
  shape = utilities.widgets.mkroundedrect(),
  widget = wibox.container.background,
})
awful.placement.bottom(osd, { margins = { bottom = dpi(100) } })

osd.osd_timeout = gears.timer({
  timeout = 1.4,
  call_now = true,
  autostart = true,
  callback = function()
    osd.visible = false
  end,
})

function osd.toggle_osd()
  if osd.visible then
    osd.osd_timeout:again()
  else
    osd.visible = true
    osd.osd_timeout:start()
  end
end

return osd
