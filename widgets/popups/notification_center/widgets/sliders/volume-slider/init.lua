--  ___ ___         __
-- |   |   |.-----.|  |.--.--.--------.-----.
-- |   |   ||  _  ||  ||  |  |        |  -__|
--  \_____/ |_____||__||_____|__|__|__|_____|

--  _______ __ __     __
-- |     __|  |__|.--|  |.-----.----.
-- |__     |  |  ||  _  ||  -__|   _|
-- |_______|__|__||_____||_____|__|
-- ------------------------------------------------- --
local widget_name = wibox.widget({
  text = "Volume",
  font = beautiful.font .. " 6",
  align = "left",
  widget = wibox.widget.textbox,
})
-- ------------------------------------------------- --
local widget_icon = wibox.widget({
  layout = wibox.layout.align.vertical,
  expand = "none",
  nil,
  {
    id = "icon",
    image = icons.volume,
    resize = true,
    widget = wibox.widget.imagebox,
  },
  nil,
})
-- ------------------------------------------------- --
local widget_content = wibox.widget({
  {
    widget_icon,
    margins = dpi(6),
    widget = wibox.container.margin,
  },
  bg = beautiful.bg_contrast .. "66",
  shape = utilities.widgets.mkroundedrect(),
  widget = wibox.container.background,
})

-- ------------------------------------------------- --
local slider = wibox.widget({
  nil,
  {
    id = "volume_slider",
    bar_shape = gears.shape.rounded_bar,
    bar_height = dpi(12),
    bar_color = beautiful.bg_normal .. "cc",
    bar_active_color = beautiful.grey .. "dd",
    handle_color = beautiful.fg_normal,
    handle_shape = utilities.widgets.mkroundedrect(),
    handle_width = dpi(12),
    handle_border_color = beautiful.bg_normal,
    handle_border_width = dpi(2),
    maximum = 100,
    value = 100,
    widget = wibox.widget.slider,
  },
  nil,
  expand = "none",
  forced_height = dpi(24),
  layout = wibox.layout.align.vertical,
})

local volume_slider = slider.volume_slider
-- ------------------------------------------------- --
volume_slider:connect_signal("property::value", function()
  local volume_level = volume_slider:get_value()
  if volume_level ~= nil then
    spawn("pamixer --set-volume " .. volume_level, false)
    awesome.emit_signal("signal::volume:update", tonumber(volume_level))
    awesome.emit_signal("signal::volume", tonumber(volume_level), 0)
    widget_icon.icon:set_image(icons.volume)
  else
    volume_slider:set_value(0)
    spawn("pamixer --mute", false)
    widget_icon.icon:set_image(icons.mute)
  end
end)
-- ------------------------------------------------- --
volume_slider:buttons(gears.table.join(
  awful.button({}, 9, nil, function()
    if volume_slider:get_value() > 100 then
      volume_slider:set_value(100)
      return
    end
    volume_slider:set_value(volume_slider:get_value() + 5)
    awesome.emit_signal("signal::volume:update", volume_slider:get_value())
  end),
  awful.button({}, 8, nil, function()
    if volume_slider:get_value() < 0 then
      volume_slider:set_value(0)
      return
    end
    volume_slider:set_value(volume_slider:get_value() - 5)

    awesome.emit_signal("signal::volume:update", volume_slider:get_value())
  end)
))
-- ------------------------------------------------- --
local update_slider_mute = function()
  awful.spawn.easy_async_with_shell([["pamixer --get-mute"]], function(stdout)
    if stdout ~= nil then
      local status = string.match(stdout, "%a+")
      if stdout == "true" then
        widget_icon.icon:set_image(icons.mute)
        awful.spawn.easy_async_with_shell([["pamixer --mute "]], false)
        awesome.emit_signal("signal:volume:mute")
      elseif status == "false" then
        awful.spawn.easy_async_with_shell(
          [["pamixer --unmute "]],
          false
        )
        awesome.emit_signal("signal:volume:unmute")
        widget_icon.icon:set_image(icons.volume)
      end
    else
      return
    end
  end)
end
-- ------------------------------------------------- --
local update_slider = function()
  awful.spawn.easy_async_with_shell("pamixer --get-volume", function(stdout)
    if stdout ~= nil then
      local volume = tonumber(stdout)
      if volume ~= nil then
        volume_slider:set_value(volume)
      end
      update_slider_mute()
    else
      local vol = volume_slider:get_value()
      update_slider_mute()
    end
  end)
end

-- Update on startup
update_slider()
-- ------------------------------------------------- --
local mute_toggle = function()
  awful.spawn.easy_async_with_shell([[ pamixer --mute]], function()
    if volume_slider:get_value() ~= 0 then
      widget_icon.icon:set_image(icons.mute)
      awesome.emit_signal("signal::volume:mute")
    else
      awesome.emit_signal("signal::volume:unmute")
      widget_icon.icon:set_image(icons.volume)
    end
  end)
end
-- ------------------------------------------------- --
widget_content:buttons(awful.util.table.join(awful.button({}, 1, nil, function()
  mute_toggle()
  update_slider_mute()
end)))
-- ------------------------------------------------- --
local volume_tooltip = awful.tooltip({
  objects = { widget_icon },
  text = "None",
  mode = "outside",
  align = "right",
  margin_leftright = dpi(8),
  margin_topbottom = dpi(8),
  preferred_positions = { "right", "left", "top", "bottom" },
})
-- ------------------------------------------------- --
-- The emit will come from the global keybind
awesome.connect_signal("signal::volume:update", function(value)
  local percentage = tonumber(value)
  if percentage ~= nil then
    update_slider()
    update_slider_mute()
    volume_tooltip:set_text(
      "Volume Level is Currently: " .. percentage .. "%"
    )
  end
end)
-- ------------------------------------------------- --
local cc_volume = wibox.widget({
  {
    {
      layout = wibox.layout.fixed.horizontal,
      spacing = dpi(5),
      {
        layout = wibox.layout.align.vertical,
        expand = "none",
        nil,
        {
          layout = wibox.layout.fixed.horizontal,
          forced_height = dpi(64),
          forced_width = dpi(64),
          widget_content,
        },
        handle_color = beautiful.sliders_fg,
        nil,
      },
      slider,
    },
    margins = dpi(15),
    widget = wibox.container.margin,
  },
  shape = utilities.widgets.mkroundedrect(),
  bg = beautiful.bg_contrast .. "66",
  fg = beautiful.fg_normal,
  widget = wibox.container.background,
})

return cc_volume
