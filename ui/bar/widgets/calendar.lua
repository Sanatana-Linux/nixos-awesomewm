--      ______         __                 __
--     |      |.---.-.|  |.-----.-----.--|  |.---.-.----.
--     |   ---||  _  ||  ||  -__|     |  _  ||  _  |   _|
--     |______||___._||__||_____|__|__|_____||___._|__|
--   +---------------------------------------------------------------+

---@diagnostic disable: undefined-global

-- listen for requests to change the visibility of the calendar in the focused screen ofc.
local function get_calendar()
  return awful.screen.focused().calendar
end

awesome.connect_signal("calendar::toggle", function()
  get_calendar().toggle()
end)

awesome.connect_signal("calendar::visibility", function(v)
  if v then
    get_calendar().show()
  else
    get_calendar().hide()
  end
end)

awful.screen.connect_for_each_screen(function(s)
  s.calendar = {}

  s.calendar.calendar = wibox.widget({
    date = os.date("*t"),
    font = beautiful.font_name .. " 10",
    spacing = dpi(2),
    widget = wibox.widget.calendar.month,
    fn_embed = function(widget, flag, date)
      local focus_widget = wibox.widget({
        text = date.day,
        align = "center",
        widget = wibox.widget.textbox,
      })

      local torender = flag == "focus" and focus_widget or widget

      local colors = {
        header = beautiful.fg_focus,
        focus = beautiful.fg_normal,
        weekday = beautiful.lessgrey,
      }

      local color = colors[flag] or beautiful.fg_focus

      return wibox.widget({
        {
          torender,
          margins = dpi(7),
          widget = wibox.container.margin,
        },
        bg = flag == "focus" and beautiful.grey .. "ff"
          or beautiful.bg_normal .. "00",
        fg = color,
        border_width = dpi(1),
        border_color = flag == "focus" and beautiful.lessgrey .. "cc"
          or beautiful.bg_normal .. "00",
        widget = wibox.container.background,
        shape = utilities.widgets.mkroundedrect(),
      })
    end,
  })

  s.calendar.popup = awful.popup({
    bg = beautiful.bg_normal .. "cc",
    border_color = beautiful.grey .. "cc",
    border_width = dpi(1),
    fg = beautiful.fg_normal,
    visible = false,
    ontop = true,
    placement = function(d)
      return awful.placement.bottom_right(d, {
        margins = {
          bottom = beautiful.bar_height + beautiful.useless_gap * 2,
          right = beautiful.useless_gap * 2,
        },
      })
    end,
    shape = utilities.widgets.mkroundedrect(),
    screen = s,
    widget = s.calendar.calendar,
  })

  local self = s.calendar.popup

  function s.calendar.show()
    self.visible = true
  end

  function s.calendar.hide()
    self.visible = false
  end

  function s.calendar.toggle()
    self.visible = not self.visible
  end
end)
