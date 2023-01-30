local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local naughty = require("naughty")
local mkroundedrect = require('utilities.mkroundedcontainer')

local complex_capitalizing=require('utilities.complex_capitalizing')
return function(n)
  return {
    {
      {
        {
          {
            {
              image = n.icon or beautiful.fallback_notif_icon,
              forced_height = 32,
              forced_width = 32,
              valign = "center",
              align = "center",
              clip_shape = gears.shape.circle,
              widget = wibox.widget.imagebox
            },
            {
              markup = complex_capitalizing(
                  n.app_name == "" and "Cannot detect app" or n.app_name),
              align = "left",
              valign = "center",
              widget = wibox.widget.textbox
            },
            spacing = dpi(10),
            layout = wibox.layout.fixed.horizontal
          },
          margins = dpi(10),
          widget = wibox.container.margin
        },
        {
          {
            {markup = "", widget = wibox.widget.textbox},
            top = 1,
            widget = wibox.container.margin
          },
          bg = beautiful.light_black,
          widget = wibox.container.background
        },
        layout = wibox.layout.fixed.vertical
      },
      {
        {
          n.title == "" and nil or {
            markup = "<b>" .. complex_capitalizing(n.title) .. "</b>",
            align = "center",
            valign = "center",
            widget = wibox.widget.textbox
          },
          {
            markup = n.title == "" and "<b>" .. n.message .. "</b>" or n.message,
            align = "center",
            valign = "center",
            widget = wibox.widget.textbox
          },
          spacing = dpi(5),
          layout = wibox.layout.fixed.vertical
        },
        top = dpi(25),
        left = dpi(12),
        right = dpi(12),
        bottom = dpi(15),
        widget = wibox.container.margin
      },
      {
        {
          notification = n,
          base_layout = wibox.widget {
            spacing = dpi(12),
            layout = wibox.layout.flex.horizontal
          },
          widget_template = {
            {
              {
                {id = "text_role", widget = wibox.widget.textbox},
                widget = wibox.container.place
              },
              top = dpi(7),
              bottom = dpi(7),
              left = dpi(4),
              right = dpi(4),
              widget = wibox.container.margin
            },
            shape = gears.shape.rounded_bar,
            bg = beautiful.black,
            widget = wibox.container.background
          },
          widget = naughty.list.actions
        },
        margins = dpi(12),
        widget = wibox.container.margin
      },
      spacing = dpi(7),
      layout = wibox.layout.align.vertical
    },
    bg = beautiful.bg_normal,
    fg = beautiful.fg_normal,
    shape = mkroundedrect(),
    widget = wibox.container.background
  }
end
