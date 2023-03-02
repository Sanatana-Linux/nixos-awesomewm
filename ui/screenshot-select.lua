---@diagnostic disable: undefined-global
--  _______                                     __           __   
-- |     __|.----.----.-----.-----.-----.-----.|  |--.-----.|  |_ 
-- |__     ||  __|   _|  -__|  -__|     |__ --||     |  _  ||   _|
-- |_______||____|__| |_____|_____|__|__|_____||__|__|_____||____|
--  _______                                                       
-- |   |   |.-----.-----.--.--.                                   
-- |       ||  -__|     |  |  |                                   
-- |__|_|__||_____|__|__|_____|                                   
-- -------------------------------------------------------------------------- --
-- screenshot menu for each screen 
-- 
awful.screen.connect_for_each_screen(function(s)
  s.screenshot_selecter = {}
  -- -------------------------------------------------------------------------- --
  -- button template function for menu items
  -- 
  local function genbutton(template, tooltip_opts, onclick)
    local button = wibox.widget {
      {template, margins = dpi(7), widget = wibox.container.margin},
      bg = beautiful.black,
      shape = utilities.mkroundedrect(),
      widget = wibox.container.background,
      border_color = beautiful.grey,
      border_width=0.75
    }
    -- -------------------------------------------------------------------------- --
    -- add hover effects, onclick listener and tooltips
    -- 
    utilities.add_hover(button, beautiful.black, beautiful.bg_focus)

    local tooltip = utilities.make_popup_tooltip(tooltip_opts.txt,
                                                 tooltip_opts.placement)

    tooltip.attach_to_object(button)

    button:add_button(awful.button({}, 1, function()
      tooltip.hide()
      s.myscreenshot_action_icon:set_markup_silently("")
      if onclick then
        onclick()
      end
    end))

    return button
  end
  -- -------------------------------------------------------------------------- --
  -- popup widget template 
  -- NOTE: this first portion lays out the wibox itself 
-- 
  s.screenshot_selecter.widget = wibox.widget {
    {
      {
        genbutton({
          text = "",
          font = beautiful.nerd_font .. " 30",
          align = "center",
          valign = "center",
          widget = wibox.widget.textbox
        }, {
          txt = "Full Screenshot",
          placement = function(d)
            return awful.placement.bottom_right(d, {
              margins = {
                bottom = (beautiful.bar_height + beautiful.useless_gap * 2) +
                    dpi(86) + (beautiful.useless_gap * 2),
                right = dpi(60) + (dpi(60) / 2.75),
                top = dpi(160)
              }
            })
          end
        }, function()
          s.screenshot_selecter.hide()
          utilities.screenshot.full()
        end),
        genbutton({
          text = "",
          font = beautiful.nerd_font .. " 30",
          align = "center",
          valign = "center",
          widget = wibox.widget.textbox
        }, {
          txt = "Area Screenshot",
          placement = function(d)
            return awful.placement.bottom_right(d, {
              margins = {
                bottom = (beautiful.bar_height + beautiful.useless_gap * 2) +
                    dpi(60) + (beautiful.useless_gap * 2),
                right = dpi(60) + (dpi(60) / 2.75),
                top = dpi(160)
              }
            })
          end
        }, function()
          s.screenshot_selecter.hide()
          utilities.screenshot.area()
        end),
        spacing = dpi(12),
        layout = wibox.layout.flex.horizontal
      },
      margins = dpi(7),
      widget = wibox.container.margin
    },
    bg = beautiful.bg_normal,
    border_color = beautiful.grey,
    border_width=1.25,
    shape = utilities.mkroundedrect(),
    widget = wibox.container.background
  }
  -- -------------------------------------------------------------------------- --
  -- NOTE: this second portion situates the wibox into 
  --       `a popup object and assigns properties to it 
  -- 
  s.screenshot_selecter.popup = awful.popup {
    ontop = true,
    placement = function(d)
      return awful.placement.bottom_right(d, {
        margins = {
          right = dpi(100),
          bottom = beautiful.bar_height + beautiful.useless_gap * 2
        }
      })
    end,
    -- the wibox already has a background colors
    -- 
    bg = beautiful.bg_normal .. "00",
    fg = beautiful.fg_normal,
    shape = utilities.mkroundedrect(),
    visible = false,
    screen = s,
    minimum_width = dpi(180),
    minimum_height = dpi(60),
    widget = s.screenshot_selecter.widget
  }

  -- -------------------------------------------------------------------------- --
  -- keygrabber
  -- 
  screenshot_kg = awful.keygrabber {
    keybindings = {
      awful.key {
        modifiers = {},
        key = "Escape",
        on_press = function()
          s.screenshot_selecter.hide()
          screenshot_kg:stop()
        end
      },
      awful.key {
        modifiers = {},
        key = "q",
        on_press = function()
          s.screenshot_selecter.hide()
          screenshot_kg:stop()
        end
      },
      awful.key {
        modifiers = {},
        key = "x",
        on_press = function()
          s.screenshot_selecter.hide()
          screenshot_kg:stop()
        end
      }
    }
  }
  -- -------------------------------------------------------------------------- --
  -- toggle function 
  -- 
  function s.screenshot_selecter.toggle()
    if s.screenshot_selecter.popup.visible then
      s.screenshot_selecter.hide()
      screenshot_kg:stop()

    else
      s.screenshot_selecter.show()
      screenshot_kg:start()
    end
  end

  function s.screenshot_selecter.hide()
    s.screenshot_selecter.popup.visible = false
    -- for coloring icon when the menu is closed
    -- 
    awesome.emit_signal("screenshot::hide")
    screenshot_kg:stop()
  end

  function s.screenshot_selecter.show()
    s.screenshot_selecter.popup.visible = true
    -- color icon when menu opened
    -- 
    awesome.emit_signal("screenshot::show")
    screenshot_kg:start()
  end
end)
-- -------------------------------------------------------------------------- --
