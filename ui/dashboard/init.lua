---@diagnostic disable: undefined-global, lowercase-global
--     __               __     __                        __ 
-- .--|  |.---.-.-----.|  |--.|  |--.-----.---.-.----.--|  |
-- |  _  ||  _  |__ --||     ||  _  |  _  |  _  |   _|  _  |
-- |_____||___._|_____||__|__||_____|_____|___._|__| |_____|
-- -------------------------------------------------------------------------- --
-- enable visibility listener.
-- 
require("ui.dashboard.listener")

-- -------------------------------------------------------------------------- --
-- dashboard for each monitor not just primary
-- 
awful.screen.connect_for_each_screen(function(s)
  s.dashboard = {}

  -- -------------------------------------------------------------------------- --
  -- function serving as a template
  -- 
  local function mkwidget()
    -- -------------------------------------------------------------------------- --
    -- locally scoped variables
    -- 
    local date = require("ui.dashboard.date")
    local charts = require("ui.dashboard.charts")
    local music = require("ui.dashboard.music-player")
    local controls = require("ui.dashboard.controls")
    local actions = require("ui.dashboard.actions")
    -- -------------------------------------------------------------------------- --
    -- widget template 
    -- 
    return wibox.widget {
      {

        {
          {
            {
              date,
              {
                controls,
                music,
                spacing = dpi(12),
                layout = wibox.layout.flex.horizontal
              },
              charts,
         
              spacing = dpi(15),
              layout = wibox.layout.fixed.vertical
            },
            margins = dpi(15),
            widget = wibox.container.margin
          },
          widget = wibox.container.background,
          shape = function(cr, w, h)
            return gears.shape.partially_rounded_rect(cr, w, h, true, true,
                                                      false, false, dpi(12))
          end
        },
        nil,
        spacing = dpi(15),
        layout = wibox.layout.align.vertical,
      },
      fg = beautiful.fg_normal,
      widget = wibox.container.background,
      shape = utilities.mkroundedrect()
    }
  end
  -- -------------------------------------------------------------------------- --
  -- popup template 
  -- 
  s.dashboard.popup = awful.popup {
    placement = function(d)
      return awful.placement.bottom(d, {
        margins = {bottom = beautiful.bar_height + beautiful.useless_gap * 4}
      })
    end,
    ontop = true,
    visible = false,
    shape = utilities.mkroundedrect(),
    minimum_width = dpi(455),
    fg = beautiful.fg_normal,
    screen = s,
      bg = beautiful.bg_normal .. 'cc',
      border_color=beautiful.grey ..'cc',
      border_width = dpi(2),
      widget = wibox.container.background
  }

  local self = s.dashboard.popup
  -- -------------------------------------------------------------------------- --
  -- creates a keygrabber so the user can close the 
  -- thing without pressing the button again
  -- 
  dash_kg = awful.keygrabber {
    keybindings = {
      awful.key {
        modifiers = {},
        key = "Escape",
        on_press = function()
          s.dashboard.toggle()
          dash_kg:stop()
        end
      },
      awful.key {
        modifiers = {},
        key = "q",
        on_press = function()
          s.dashboard.toggle()
          dash_kg:stop()
        end
      },
      awful.key {
        modifiers = {},
        key = "x",
        on_press = function()
          s.dashboard.toggle()
          dash_kg:stop()
        end
      }
    }
  }
  -- -------------------------------------------------------------------------- --
  -- solves performance and keygrabbing issues
  -- 
  function s.dashboard.toggle()
    if self.visible then
      s.dashboard.hide()
      dash_kg:stop()
      collectgarbage("collect")
    else
      s.dashboard.show()
      dash_kg:start()
      collectgarbage("collect")
    end
  end

  function s.dashboard.show()
    dash_kg:start()
    if not PlayerctlSignal then
      PlayerctlSignal = require"plugins.bling".signal.playerctl.lib()
    end
    if not PlayerctlCli then
      PlayerctlCli = require"plugins.bling".signal.playerctl.cli()
    end
    self.widget = mkwidget()
    self.visible = true
    collectgarbage("collect")
  end

  function s.dashboard.hide()
    dash_kg:stop()
    self.visible = false
    if PlayerctlCli then
      PlayerctlCli:disable()
      PlayerctlCli = nil
    end
    self.widget = wibox.widget {
      bg = beautiful.bg_normal,
      widget = wibox.container.background
    }
    collectgarbage("collect")
  end
end)
