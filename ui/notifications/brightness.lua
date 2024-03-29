-- the brightness OSD that is displayed when adjusting
-- the brightness with keys or dashboard widgets
local dpi = beautiful.xresources.apply_dpi

local width = dpi(200)
local height = dpi(200)
local screen = awful.screen.focused()
-- ------------------------------------------------- --
-- brightness icon defined as icons.brightness
local bright_icon = wibox.widget({
  id = "popup_icon",
  image = icons.brightness,
  align = "center",
  forced_height = dpi(72),
  forced_width = dpi(72),
  valign = "center",
  widget = wibox.widget.imagebox(),
})
-- ------------------------------------------------- --
-- create the bright_adjust component
local bright_adjust = wibox({
  screen = screen.focused,
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
-- bar underneath the icon
local bright_bar = wibox.widget({
  widget = wibox.widget.progressbar,
  shape = gears.shape.rounded_bar,
  bar_shape = gears.shape.rounded_bar,
  color = beautiful.fg_normal,
  background_color = beautiful.bg_normal .. "66",
  max_value = 100,
  value = 100,
})
-- ------------------------------------------------- --
-- create OSD template
bright_adjust:setup({
  {
    layout = wibox.layout.align.vertical,
    {
      bright_icon,
      top = dpi(35),
      left = dpi(65),
      right = dpi(65),
      bottom = dpi(35),
      widget = wibox.container.margin,
    },
    {
      bright_bar,
      left = dpi(25),
      right = dpi(25),
      bottom = dpi(30),
      widget = wibox.container.margin,
    },
  },
  shape = utilities.graphics.mkroundedrect(),
  bg = beautiful.bg_normal .. "66",
  border_width = dpi(2),
  border_color = beautiful.grey .. "cc",
  widget = wibox.container.background,
})

-- ------------------------------------------------- --
-- adjust bar value based on brightness level

local bright_adjust_timeout = gears.timer({
  timeout = 3,
  call_now = true,
  autostart = true,
  callback = function()
    bright_adjust.visible = false
  end,
})
--   +---------------------------------------------------------------+
local function toggle_bright_adjust()
  if bright_adjust.visible == true then
    bright_adjust.visible = false
    bright_adjust_timeout:stop()
  else
    bright_adjust.visible = true
    bright_adjust_timeout:again()
  end
end
local percentage_old = -1
-- ------------------------------------------------- --
-- connect to signal about brightness changes
awesome.connect_signal("signal::brightness", function(percentage)
  if percentage_old ~= percentage then
    if percentage ~= nil then
      bright_bar:set_value(percentage)
      toggle_bright_adjust()
    end
  end

  percentage_old = percentage
end)
