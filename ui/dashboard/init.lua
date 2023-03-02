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
              {
                {
                  {
                    actions.network,
                    actions.airplane,
                    actions.volume,
                    actions.redshift,
                    actions.bluetooth,
                    spacing = dpi(10),
                    layout = wibox.layout.flex.horizontal,
                    border_color = beautiful.grey
                  },
                  margins = dpi(15),
                  widget = wibox.container.margin
                },
                shape = utilities.mkroundedrect(dpi(15)),
                bg = beautiful.bg_lighter,
                widget = wibox.container.background,
                border_width = 0.75,
                border_color = beautiful.grey,
              },
              spacing = dpi(15),
              layout = wibox.layout.fixed.vertical
            },
            margins = dpi(15),
            widget = wibox.container.margin
          },
          bg = beautiful.bg_normal,
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
      bg = beautiful.black,
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
    bg = "#00000000",
    minimum_width = dpi(455),
    fg = beautiful.fg_normal,
    screen = s,
    widget = wibox.widget {
      bg = beautiful.bg_normal,
      widget = wibox.container.background
    }
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
    else
      s.dashboard.show()
      dash_kg:start()
    end
  end

  function s.dashboard.show()
    if not PlayerctlSignal then
      PlayerctlSignal = require"plugins.bling".signal.playerctl.lib()
    end
    if not PlayerctlCli then
      PlayerctlCli = require"plugins.bling".signal.playerctl.cli()
    end
    self.widget = mkwidget()
    self.visible = true
  end

  function s.dashboard.hide()
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
