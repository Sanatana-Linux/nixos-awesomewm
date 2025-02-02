local helpers = require("helpers")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local awful = require("awful")
local wibox = require("wibox")

local widget = wibox.widget {
  {
    {
      {
        {
          font = beautiful.sans .. " 16",
          markup = helpers.colorize_text("All our dreams can come true if we have the courage to pursue them", beautiful.fg),
          widget = wibox.widget.textbox,
          valign = "start",
          align = "center"
        },
        {

          font = beautiful.sans .. " Bold 12",
          markup = helpers.colorize_text("Walt Disney", beautiful.magenta),
          widget = wibox.widget.textbox,
          valign = "start",
          align = "center"
        },
        spacing = dpi(20),
        layout = wibox.layout.fixed.vertical,
      },
      widget = wibox.container.margin,
      margins = dpi(30)
    },
    widget = wibox.container.background,
    bg = beautiful.mbg,
    shape = helpers.rrect(20),
  },
  widget = wibox.container.margin,
  top = dpi(20)
}

return widget
