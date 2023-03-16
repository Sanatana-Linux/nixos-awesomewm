local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi

local notifwidget = require "ui.bar.popups.notification_center.widgets.notifcenter"


local function init(s)
  local cent_width = dpi(450)
  local height = s.geometry.height * (3 / 5)
  s.notification_center = wibox {
    screen = s,
    x = s.geometry.x + s.geometry.width - cent_width - 2 * beautiful.useless_gap,
    y = s.geometry.y +s.geometry.height - ( 2 * beautiful.useless_gap +
        beautiful.bar_height + height),
    width = cent_width,
    height = height,
    ontop = true,
    visible = false,
    widget = wibox.widget {
      widget = wibox.container.margin,
      margins = dpi(10),
      {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(10),
        notifwidget
      }
    }
  }


  function s.notification_center:show()
    self.visible = true
  end
  function s.notification_center:hide()
    self.visible = false
  end
  function s.notification_center:toggle()
    if self.visible == true then
      self.visible = false

    else
      self.visible = true
    end
  end

      -- -------------------------------------------------------------------------- --
  -- keygrabber
  -- 
  keygrabber_no = awful.keygrabber {
    keybindings = {
      awful.key {
        modifiers = {},
        key = "Escape",
        on_press = function()
          s.notification_center:hide()
          keygrabber_no:stop()
        end
      },
      awful.key {
        modifiers = {},
        key = "q",
        on_press = function()
          s.notification_center:hide()
          keygrabber_no:stop()
        end
      },
      awful.key {
        modifiers = {},
        key = "x",
        on_press = function()
          s.notification_center:hide()
          keygrabber_no:stop()
        end
      }
    }
  }
-- -------------------------------------------------------------------------- --
  local function show(s)
    s.notification_center.visible = true
    keygrabber_no:start()
  end

  local function hide(s)
    s.notification_center.visible = false
    keygrabber_no:stop()
  end

awesome.connect_signal("notification_center::toggle",function(s)
    if s.notification_center.visible == true then
      s.notification_center.visible = false
      keygrabber_no:stop()
    else
      s.notification_center.visible = true
      keygrabber_no:start()
    end
  end)

end
return {init = init, show = show, hide = hide, toggle = toggle}
