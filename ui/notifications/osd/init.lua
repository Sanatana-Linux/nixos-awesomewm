-- requirements
-- ~~~~~~~~~~~~
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local osd = {}
-- widgets themselves
-- ~~~~~~~~~~~~~~~~~~

-- icon
local icon = wibox.widget({
  widget = wibox.widget.imagebox,
  forced_width = dpi(48),
  forced_height = dpi(48),
  align = "center",
  valign = "center",
  halign = "center",
})

-- progress bar
local bar = wibox.widget({
  bar_color = beautiful.bg_contrast,
  handle_color = beautiful.fg_normal,
  handle_shape = utilities.widgets.mkroundedrect(),
  handle_width = dpi(18),
  bar_active_color = beautiful.fg_normal,
  bar_height = dpi(8),
  bar_width = dpi(80),
  minimum = 0,
  maximum = 100,
  widget = wibox.widget.slider,
})

-- actual popup
local pop = wibox({

  type = "notification",

  screen = awful.screen.focused(),
  height = dpi(180),
  width = dpi(55),
  shape = utilities.widgets.mkroundedrect(),
  bg = beautiful.bg_normal .. "99",
  border_width = dpi(1),
  border_color = beautiful.fg_normal .. "99",
  halign = "center",
  valign = "center",
  ontop = true,
  visible = false,
})

-- placement
awful.placement.right(pop, { margins = { right = beautiful.useless_gap * 2 } })

-- tuemout
local timeout = gears.timer({
  autostart = true,
  timeout = 2.4,
  single_shot = true,
  callback = function()
    pop.visible = false
  end,
})

local function toggle_pop()
  if pop.visible == true then
    pop.visible = false
    timeout:stop()
  else
    pop.visible = true
    timeout:start()
  end
end

pop:setup({
  {
    {
      bar,
      forced_height = dpi(100),
      forced_width = dpi(15),
      direction = "east",
      widget = wibox.container.rotate,
    },
    margins = dpi(15),
    layout = wibox.container.margin,
  },
  {
    icon,
    margins = { bottom = dpi(10) },
    widget = wibox.container.margin,
  },
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

-- update widgets accordingly
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~

-- volume
local first_V = true
awesome.connect_signal("signal::volume", function(value, muted)
  if first_V then
    first_V = false
  else
    if value ~= nil and value >= 1 or value <= 100 then
      bar.value = value
      icon.image = icons.volume_up
    end
    if muted or value == 0 then
      bar.handle_color = beautiful.red
      bar.bar_active_color = beautiful.red
      icon.image = icons.mute
    else
      bar.handle_color = beautiful.fg_normal
      bar.bar_active_color = beautiful.fg_normal
      icon.image = icons.volume_up
    end

    toggle_pop()
  end
end)

-- brightness
local first_B = true
awesome.connect_signal("signal::brightness", function(value)
  if first_B then
    first_B = false
  else
    icon.image = icons.brightness
    bar.handle_color = beautiful.fg_normal
    bar.bar_active_color = beautiful.fg_normal
    bar.value = value
    toggle_pop()
  end
end)

return osd
