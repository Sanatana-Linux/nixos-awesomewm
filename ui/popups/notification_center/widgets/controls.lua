---@diagnostic disable: undefined-global
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi

local function base_slider(icon)
  return wibox.widget({
    {
      {
        id = "slider",
        bar_shape = utilities.graphics.mkroundedrect(),
        bar_height = dpi(18),
        bar_active_color = beautiful.grey .. "88",
        bar_color = beautiful.black .. "88",
        handle_color = beautiful.white,
        handle_shape = utilities.graphics.mkroundedrect(),
        handle_width = dpi(18),
        handle_border_width = dpi(1),
        forced_height = dpi(18),
        handle_border_color = beautiful.bg_normal,
        minimum = 5,
        maximum = 100,
        widget = wibox.widget.slider,
      },
      {
        {
          {
            id = "icon_role",
            markup = icon,
            valign = "center",
            align = "left",
            font = beautiful.nerd_font .. " 28",
            widget = wibox.widget.textbox,
          },
          fg = beautiful.fg_normal,
          widget = wibox.container.background,
        },
        left = dpi(7),
        widget = wibox.container.margin,
      },
      layout = wibox.layout.stack,
    },
    layout = wibox.layout.fixed.horizontal,
    set_value = function(self, value)
      self:get_children_by_id("slider")[1].value = value
    end,
    set_icon = function(self, new_icon)
      self:get_children_by_id("icon_role")[1].markup = new_icon
    end,
    get_slider = function(self)
      return self:get_children_by_id("slider")[1]
    end,
  })
end

-- volume
local volume_slider = base_slider("")

volume_slider.slider:connect_signal("property::value", function(_, value)
  awful.spawn.with_shell("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0")
  awful.spawn.with_shell(
    "wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. value .. "%"
  )
  awesome.emit_signal("widget::volume")
end)

awesome.connect_signal("signal::volume", function(volume, is_muted)
  volume_slider.value = volume
  if is_muted == "MUTED" then
    volume_slider.icon = ""
  else
    volume_slider.icon = ""
  end
end)

-- brightness
local brightness_slider = base_slider("")

-- 100 by-default.
if brightness_slider.slider.value == 0 then
  brightness_slider.value = 100
end

-- signals
brightness_slider.slider:connect_signal("property::value", function(_, new_br)
  awful.spawn("brightnessctl s " .. new_br .. "%")
  awesome.emit_signal("signal::brightness", math.floor(new_br))
end)

awesome.connect_signal("brightness::value", function(brightness)
  brightness_slider.value = brightness
  brightness_slider.icon = brightness == 0 and "" or ""
end)

local controls = wibox.widget({
  {
    {
      {
        {
          {
            bottom = dpi(8),
            widget = wibox.container.margin,
          },
          widget = wibox.container.background,
        },
        layout = wibox.layout.fixed.horizontal,
      },
      {
        volume_slider,
        brightness_slider,
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical,
      },
      nil,
      layout = wibox.layout.align.vertical,
    },
    margins = dpi(12),
    widget = wibox.container.margin,
  },
  shape = utilities.graphics.mkroundedrect(),
  bg = beautiful.bg_contrast,
  border_color = beautiful.grey,
  border_width = 0.75,
  widget = wibox.container.background,
})

return controls
