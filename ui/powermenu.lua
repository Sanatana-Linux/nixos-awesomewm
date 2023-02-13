---@diagnostic disable: undefined-global
-- .-----.-----.--.--.--.-----.----.
-- |  _  |  _  |  |  |  |  -__|   _|
-- |   __|_____|________|_____|__|  
-- |__|                             
-- .--------.-----.-----.--.--.     
-- |        |  -__|     |  |  |     
-- |__|__|__|_____|__|__|_____|     
-- -------------------------------------------------------------------------- --
-- signals
-- 
awesome.connect_signal("powermenu::toggle", function()
  local screen = awful.screen.focused()
  local powermenu = screen.powermenu
  powermenu.toggle()
end)
-- -------------------------------------------------------------------------- --
awesome.connect_signal("powermenu::visibility", function(visibility)
  local screen = awful.screen.focused()
  local powermenu = screen.powermenu
  if visibility then
    powermenu.show()
    exit_kg:start()
  else
    powermenu.hide()
    exit_kg:stop()
  end
end)
-- -------------------------------------------------------------------------- --
-- button function template
local function make_powerbutton(opts)
  local default_widget = function(font, align)
    return wibox.widget {
      markup = "⏻",
      font = font,
      align = align,
      halign = "center",
      valign = "center",
      widget = wibox.widget.textbox
    }
  end
  -- -------------------------------------------------------------------------- --
  -- default options 
  if not opts then
    opts = {
      widget = default_widget,
      onclick = function()
      end,
      bg = beautiful.bg_lighter
    }
  end

  opts.bg = opts.bg and opts.bg or beautiful.bg_lighter

  -- -------------------------------------------------------------------------- --
  -- provide markup for text that icons are derived from
  local call_widget = function()
    local icon_font = beautiful.nerd_font .. " 64"
    local align = "center"
    -- -------------------------------------------------------------------------- --
    -- for alignment 
    if opts.widget ~= nil then
      return opts.widget(icon_font, align)
    else
      return default_widget(icon_font, align)
    end
  end
  -- -------------------------------------------------------------------------- --
  -- button template
  local button = wibox.widget {
    {
      call_widget(),
      top = dpi(2),
      bottom = dpi(2),
      left = dpi(18),
      right = dpi(18),
      widget = wibox.container.margin
    },
    widget = wibox.container.background,
    bg = opts.bg,
    border_color = beautiful.grey,
    border_width = 0.75,
    shape = gears.shape.rounded_rect
  }
  -- -------------------------------------------------------------------------- --
  -- add hover support just when background is bg_lighter
  --   
  if opts.bg == beautiful.bg_lighter then
    utilities.add_hover(button, beautiful.bg_lighter, beautiful.dimblack)
  end
  -- -------------------------------------------------------------------------- --
  -- provide listener for different button's actions
  button:add_button(awful.button({}, 1, function()
    if opts.onclick then
      opts.onclick()
    end
  end))

  return button
end
-- -------------------------------------------------------------------------- --
-- template for the button row 
-- 
local powerbuttons = wibox.widget {
  -- -------------------------------------------------------------------------- --
  -- poweroff
  --   
  make_powerbutton {
    widget = function(icon_font, align)
      return wibox.widget {
        {
          markup = "⏻",
          align = align,
          font = icon_font,
          widget = wibox.widget.textbox
        },
        fg = beautiful.fg_normal,
        widget = wibox.container.background
      }
    end,
    onclick = function()
      awful.spawn.with_shell("doas poweroff")
    end
  },
  -- -------------------------------------------------------------------------- --
  -- reboot
  --   
  make_powerbutton {
    widget = function(font, align)
      return wibox.widget {
        {
          markup = "勒",
          align = align,
          font = font,
          widget = wibox.widget.textbox
        },
        fg = beautiful.fg_normal,
        widget = wibox.container.background
      }
    end,
    onclick = function()
      awful.spawn.with_shell("doas reboot")
    end
  },
  -- -------------------------------------------------------------------------- --
  -- logout 
  -- 
  make_powerbutton {
    widget = function(font, align)
      return wibox.widget {
        {
          markup = "",
          align = align,
          font = font,
          widget = wibox.widget.textbox
        },
        fg = beautiful.fg_normal,
        widget = wibox.container.background
      }
    end,
    onclick = function()
      awful.spawn.with_shell("pkill awesome")
    end
  },
  -- -------------------------------------------------------------------------- --
  --   return to awesome 
  -- 
  make_powerbutton {
    widget = function(font, align)
      return wibox.widget {
        {
          markup = "",
          align = align,
          font = font,
          widget = wibox.widget.textbox
        },
        fg = beautiful.fg_normal,
        widget = wibox.container.background
      }
    end,
    onclick = function()
      awesome.emit_signal("powermenu::visibility", false)
    end
  },
  spacing = dpi(64),
  layout = wibox.layout.fixed.horizontal
}
-- -------------------------------------------------------------------------- --

awful.screen.connect_for_each_screen(function(s)
  s.powermenu = {}

  s.powermenu.widget = wibox.widget {
    {
      {markup = "", widget = wibox.widget.textbox},
      bg = "#000000",
      widget = wibox.container.background,
      opacity = 0.12
    },
    {
      {
        {
          {
            {
              image = beautiful.launcher_icon,
              forced_height = 250,
              forced_width = 250,
              halign = "center",

              widget = wibox.widget.imagebox
            },
            {

              {
                markup = "Leaving So Soon?",
                align = "center",
                widget = wibox.widget.textbox
              },
              spacing = dpi(2),
              layout = wibox.layout.fixed.vertical
            },
            {
              powerbuttons,
              widget = wibox.container.margin,
              top = dpi(10),
              bottom = dpi(10)
            },
            spacing = dpi(7),
            layout = wibox.layout.fixed.vertical
          },
          margins = dpi(12),
          widget = wibox.container.margin
        },
        fg = beautiful.fg_normal,
        shape = utilities.mkroundedrect(),
        widget = wibox.container.background
      },
      halign = "center",
      valign = "center",
      widget = wibox.container.margin,
      layout = wibox.container.place
    },
    layout = wibox.layout.stack
  }

  s.powermenu.splash = wibox {
    widget = s.powermenu.widget,
    screen = s,
    type = "splash",
    visible = false,
    ontop = true,
    bg = beautiful.bg_normal .. "80",
    height = s.geometry.height,
    width = s.geometry.width,
    x = s.geometry.x,
    y = s.geometry.y
  }

  exit_kg = awful.keygrabber {
    keybindings = {
      awful.key {
        modifiers = {},
        key = "Escape",
        on_press = function()
          s.powermenu.toggle()
          exit_kg:stop()
        end
      },
      awful.key {
        modifiers = {},
        key = "q",
        on_press = function()
          s.powermenu.toggle()
          exit_kg:stop()
        end
      },
      awful.key {
        modifiers = {},
        key = "x",
        on_press = function()
          s.powermenu.toggle()
          exit_kg:stop()
        end
      }
    }
  }
  local self = s.powermenu.splash

  function s.powermenu.toggle()
    if self.visible then
      s.powermenu.hide()
    else
      s.powermenu.show()
      exit_kg:start()
    end
  end

  function s.powermenu.show()
    self.visible = true
  end

  function s.powermenu.hide()
    self.visible = false
  end
end)
