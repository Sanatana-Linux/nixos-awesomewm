---@diagnostic disable: undefined-global
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local dpi = beautiful.xresources.apply_dpi

local volume = wibox.widget({
  widget = wibox.widget.imagebox,
  forced_height = dpi(24),
  forced_width = dpi(24),
  image = icons.volume_high,
  halign = "center",
  valign = "bottom",
})

local tooltip = utilities.widgets.make_popup_tooltip(
  "Press to mute/unmute",
  function(d)
    return awful.placement.bottom_right(d, {
      margins = {
        bottom = beautiful.bar_height + beautiful.useless_gap * 2,
        right = beautiful.useless_gap * 2 + 75,
      },
    })
  end
)

tooltip.attach_to_object(volume)

volume:add_button(awful.button({}, 1, function()
  modules.sfx.muteVolume()
end))

awesome.connect_signal("signal::volume", function(vol, is_muted)
  if vol == 0 or is_muted == 1 then
    volume.image = icons.volume_off
  else
    volume.image = icons.volume_high
  end
end)

return volume
