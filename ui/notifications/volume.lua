--  ___ ___         __
-- |   |   |.-----.|  |.--.--.--------.-----.
-- |   |   ||  _  ||  ||  |  |        |  -__|
--  \_____/ |_____||__||_____|__|__|__|_____|
--  _______ _______ _____
-- |       |     __|     \
-- |   -   |__     |  --  |
-- |_______|_______|_____/
-- ------------------------------------------------- --
local screen = awful.screen.focused()
local height = dpi(200)
local width = dpi(200)

local volume_osd_icon = wibox.widget({
  image = icons.volume,
  align = "center",
  forced_height = dpi(72),
  forced_width = dpi(72),
  valign = "center",
  widget = wibox.widget.imagebox(),
})
-- ------------------------------------------------- --
local volume_osd_bar = wibox.widget({
  nil,
  {
    id = "volume_osd_progressbar",
    max_value = 100,
    value = 0,
    background_color = beautiful.bg_normal .. "66",
    color = beautiful.white,
    border_width = dpi(1),
    border_color = beautiful.grey .. "66",
    shape = gears.shape.rounded_bar,
    bar_shape = utilities.widgets.mkroundedrect(),
    widget = wibox.widget.progressbar,
  },
  nil,
  expand = "none",
  layout = wibox.layout.align.vertical,
})
-- ------------------------------------------------- --
local volume_osd = wibox({
  type = "notification",
  x = screen.geometry.width / 2 - width / 2,
  y = screen.geometry.height / 2 - height / 2,
  width = width,
  height = height,
  visible = false,
  ontop = true,
  bg = beautiful.bg_normal .. "66",
})

-- ------------------------------------------------- --
volume_osd:setup({
  {
    layout = wibox.layout.align.vertical,
    {
      volume_osd_icon,
      top = dpi(35),
      left = dpi(65),
      right = dpi(65),
      bottom = dpi(35),
      widget = wibox.container.margin,
    },
    {
      volume_osd_bar,
      left = dpi(25),
      right = dpi(25),
      bottom = dpi(30),
      widget = wibox.container.margin,
    },
  },
  shape = utilities.widgets.mkroundedrect(),
  bg = beautiful.bg_normal .. "66",
  border_width = dpi(2),
  border_color = beautiful.grey .. "cc",
  widget = wibox.container.background,
})
-- ------------------------------------------------- --
local volume_osd_timeout = gears.timer({
  timeout = 3,
  autostart = true,
  callback = function()
    volume_osd.visible = false
  end,
})
-- ------------------------------------------------- --
local function toggle_volume_osd()
  if volume_osd.visible == true then
    volume_osd.visible = false
    volume_osd_timeout:stop()
  else
    volume_osd.visible = true
    volume_osd_timeout:again()
  end
end
-- ------------------------------------------------- --
awesome.connect_signal("signal::volume", function(value, muted)
  if muted ~= 1 then
    volume_osd_bar.volume_osd_progressbar.value = value
    volume_osd_icon.image = icons.volume
    volume_osd_bar.volume_osd_progressbar.color = beautiful.fg_normal
    toggle_volume_osd()
  else
    volume_osd_icon.image = icons.muted
    volume_osd_bar.volume_osd_progressbar.color = beautiful.lessgrey
    toggle_volume_osd()
  end
end)
