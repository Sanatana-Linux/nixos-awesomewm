local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")
local wibox = require("wibox")
local gears = require("gears")

local calendar = require("ui.moment.mods.calendar")
local weather = require("ui.moment.mods.weather")
local clock = require("ui.moment.mods.clock")

awful.screen.connect_for_each_screen(function(s)
  local moment = wibox({
    shape = helpers.rrect(12),
    screen = s,
    width = 400,
    height = awful.screen.focused().geometry.height - 40 - 60, -- makes it responsive!
    bg = beautiful.bg,
    ontop = true,
    visible = false,
  })

  moment:setup {
    {
      {
        {
          clock,
          calendar(),
          weather,
          layout = wibox.layout.fixed.vertical,
          spacing = 20,
        },
        widget = wibox.container.margin,
        margins = 20,
      },
      nil,
      layout = wibox.layout.align.vertical,
      spacing = 20,
    },
    widget = wibox.container.margin,
    margins = 0,
  }
  awful.placement.bottom_right(moment, { honor_workarea = true, margins = 20 })
  awesome.connect_signal("toggle::moment", function()
    moment.visible = not moment.visible
  end)
end)
