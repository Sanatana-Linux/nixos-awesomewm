local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi




local notifbox = {}

notifbox.create = function(icon, n, width)
  local time = os.date("%H:%M")
  local box = {}

  local dismiss = utilities.complex_button.create_image_onclick(beautiful.delete_grey_icon,
                                              beautiful.delete_icon, function()
    _G.remove_notifbox(box)
  end)
  dismiss.forced_height = dpi(14)
  dismiss.forced_width = dpi(14)

  box = wibox.widget {
    {
      {
        {
          {
            {
              {
                image = icon,
                resize = true,
                clip_shape = utilities.mkroundedrect(),
                widget = wibox.widget.imagebox
              },

              strategy = "exact",
              height = 40,
              width = 40,
              widget = wibox.container.constraint
            },
            layout = wibox.layout.align.vertical
          },
          top = dpi(13),
          left = dpi(15),
          right = dpi(15),
          bottom = dpi(13),
          widget = wibox.container.margin
        },
        {
          {
            nil,
            {
              {
                {
                  step_function = wibox.container.scroll.step_functions
                      .waiting_nonlinear_back_and_forth,
                  speed = 50,
                  {
                    markup = "<b>" .. n.title .. "</b>",
                    font = beautiful.font,
                    align = "left",
                    widget = wibox.widget.textbox
                  },
                  forced_width = dpi(204),
                  widget = wibox.container.scroll.horizontal
                },
                {
                  {
                    markup = time,
                    align = "right",
                    font = beautiful.font,
                    widget = wibox.widget.textbox
                  },
                  left = dpi(10),
                  widget = wibox.container.margin
                },
                {
                  {dismiss, halign = "right", widget = wibox.container.place},
                  left = dpi(10),
                  widget = wibox.container.margin
                },
                layout = wibox.layout.fixed.horizontal
              },
              {
                markup = n.message,
                align = "left",
                font = beautiful.font,
                widget = wibox.widget.textbox
              },
              layout = wibox.layout.fixed.vertical
            },
            nil,
            expand = "none",
            layout = wibox.layout.align.vertical
          },
          margins = dpi(8),
          widget = wibox.container.margin
        },
        layout = wibox.layout.align.horizontal
      },
      top = dpi(2),
      bottom = dpi(2),
      widget = wibox.container.margin
    },
    bg = beautiful.black .. "55",
    shape = utilities.mkroundedrect(),
    widget = wibox.container.background
  }

  return box
end

return notifbox
