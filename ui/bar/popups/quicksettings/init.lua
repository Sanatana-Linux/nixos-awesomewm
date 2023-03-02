local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi

local notifwidget = require "ui.bar.popups.quicksettings.widgets.notifcenter"
-- local pctlwidget = require "ui.bar.popups.quicksettings.widgets.playerctl"
-- local volumewidget = require "ui.bar.popups.quicksettings.widgets.volume"

local function init(s)
  local cent_width = dpi(450)
  local height = s.geometry.height * (2 / 5)
  s.quicksettings = wibox {
    screen = s,
    x = s.geometry.x + s.geometry.width - cent_width - 2 * beautiful.useless_gap,
    y = s.geometry.y + --[[s.geometry.height - (]] 2 * beautiful.useless_gap +
        beautiful.bar_height, -- + height),
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
        --	volumewidget,
        -- pctlwidget,
        notifwidget
      }
    }
  }
  function s.quicksettings:show()
    self.visible = true
  end
  function s.quicksettings:hide()
    self.visible = false
  end
  function s.quicksettings:toggle()
    if self.visible == true then
      self.visible = false

    else
      self.visible = true
    end
  end

  local function show(s)
    s.quicksettings.visible = true
    pctlwidget:enable_updates()
  end

  local function hide(s)
    s.quicksettings.visible = false
    pctlwidget:disable_updates()
  end

awesome.connect_signal("quicksettings::toggle",function(s)
    if s.quicksettings.visible == true then
      s.quicksettings.visible = false
    else
      s.quicksettings.visible = true
    end
  end)

end
return {init = init, show = show, hide = hide, toggle = toggle}
