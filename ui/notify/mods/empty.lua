local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")
local wibox = require("wibox")
local gears = require("gears")

return wibox.widget {
  {
    {
      {
        widget = wibox.widget.textbox,
        markup = helpers.colorize_text("No Notifications", beautiful.fg),
        font = beautiful.prompt_font .. " 32",
        valign = "center",
        align = "center"
      },
      {
        image = gears.filesystem.get_configuration_dir() .. "/theme/assets/no-bell.png",
        resize = true,
        forced_height = 200,
        halign = "center",
        valign = "center",
        widget = wibox.widget.imagebox,
      },
      spacing = 20,
      layout = wibox.layout.fixed.vertical
    },
    widget = wibox.container.place,
    valign = 'center'
  },
  widget = wibox.container.background,
  forced_height = 600,
}
