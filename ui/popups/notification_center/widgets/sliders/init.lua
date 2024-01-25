--         __ __     __
-- .-----.|  |__|.--|  |.-----.----.
-- |__ --||  |  ||  _  ||  -__|   _|
-- |_____||__|__||_____||_____|__|
-- ------------------------------------------------- --
local sliders = wibox.widget({
  {
    layout = wibox.layout.flex.horizontal,
    {

      layout = wibox.layout.flex.vertical,
      spacing = dpi(15),
      {
        {
          {
            require(
              "ui.popups.notification_center.widgets.sliders.volume-slider"
            ),
            forced_height = dpi(85),
            widget = wibox.container.background,
          },
          widget = wibox.container.margin,
          margins = dpi(3),
        },
        widget = wibox.container.background,
        bg = beautiful.bg_contrast .. "bb",
        border_color = beautiful.grey .. "cc",
        border_width = dpi(2),
        shape = utilities.graphics.mkroundedrect(),
      },
      {
        {
          {
            require(
              "ui.popups.notification_center.widgets.sliders.brightness-slider"
            ),
            forced_height = dpi(85),
            widget = wibox.container.background,
          },
          widget = wibox.container.margin,
          margins = dpi(3),
        },
        widget = wibox.container.background,
        bg = beautiful.bg_normal .. "66",
        border_color = beautiful.grey .. "cc",
        border_width = dpi(1),
        shape = utilities.graphics.mkroundedrect(),
      },
    },
    margins = dpi(0),
    widget = wibox.container.margin,
  },
  shape = utilities.graphics.mkroundedrect(),
  widget = wibox.container.background,
})
-- ------------------------------------------------- --
return sliders
