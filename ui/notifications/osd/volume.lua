local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local Separator = wibox.widget.textbox("   ")
Separator.forced_height = dpi(300)
Separator.forced_width = dpi(300)

---------------------------
--Volume Icon Image--------
---------------------------

local image = wibox.widget({
  image = icons.volume_high,
  widget = wibox.widget.imagebox,
  resize = true,
  forced_height = dpi(200),
  forced_width = dpi(200),
  halign = "center",
})

----------------------------
--Slider--------------------
----------------------------

local volume_slider = wibox.widget({
  widget = wibox.widget.slider,
  bar_shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, 15)
  end,
  bar_height = dpi(15),
  bar_color = beautiful.bg_contrast,
  bar_active_color = beautiful.lesswhite,
  handle_shape = gears.shape.circle,
  handle_color = beautiful.lesswhite,
  handle_width = dpi(15),
  handle_border_width = 1,
  handle_border_color = beautiful.bg_normal,
  minimum = 0,
  maximum = 100,
  value = 69,
})

-- Add signal to set the Volume using amixer
volume_slider:connect_signal("property::value", function(slider)
  local volume_level = math.floor(slider.value / 100 * 100)
  awful.spawn("amixer set Master " .. volume_level .. "%")
end)

----------------------------
--Volume Text Box-----------
----------------------------
local volume_text = wibox.widget({
  markup = '<span color="'
    .. beautiful.fg_normal
    .. '" >'
    .. "Volume"
    .. "</span>",
  widget = wibox.widget.textbox,
  fg = beautiful.fg_normal,
})

local volume_percentage = wibox.widget({
  markup = '<span color="'
    .. beautiful.fg_normal
    .. '" >'
    .. volume_slider.value
    .. "</span>",
  widget = wibox.widget.textbox,
  fg = beautiful.fg_normal,
})

local update_volume_slider = function()
  awful.spawn.easy_async("amixer sget Master", function(stdout)
    local volume = tonumber(string.match(stdout, "(%d?%d?%d)%%"))
    volume_slider.value = volume
    volume_percentage.markup = '<span color="'
      .. beautiful.fg_normal
      .. '" >'
      .. volume
      .. "</span>"
  end)
end

local volume_slider_timer = gears.timer({
  timeout = 1,
  call_now = true,
  autostart = true,
  callback = update_volume_slider,
})

----------------------------
--Main Osd popup box--------
----------------------------

local osd_box = awful.popup({
  screen = s,
  widget = wibox.container.background,
  ontop = true,
  bg = "#00000000",
  visible = false,
  placement = function(c)
    awful.placement.bottom(
      c,
      { margins = { top = dpi(8), bottom = dpi(80), left = 0, right = 0 } }
    )
  end,
  opacity = 1,
})

osd_box:setup({
  {
    {
      {
        image,
        widget = wibox.container.margin,
        top = dpi(15),
        bottom = dpi(0),
        right = dpi(50),
        left = dpi(50),
      },
      {
        {
          volume_text,
          nil,
          volume_percentage,
          layout = wibox.layout.align.horizontal,
        },
        widget = wibox.container.margin,
        left = dpi(25),
        right = dpi(27),
        top = dpi(0),
        bottom = dpi(15),
      },
      {
        volume_slider,
        widget = wibox.container.margin,
        bottom = dpi(15),
        top = dpi(0),
        left = dpi(25),
        right = dpi(25),
        forced_height = dpi(30),
        forced_width = dpi(270),
      },
      widget = wibox.container.place,
      halign = "center",
      layout = wibox.layout.fixed.vertical,
    },
    Separator,
    layout = wibox.layout.stack,
  },
  widget = wibox.container.background,
  bg = beautiful.bg_normal .. "99",
  shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, 15)
  end,
})

return osd_box
