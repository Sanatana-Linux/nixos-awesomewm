---@diagnostic disable: undefined-global
--  _______ __ __   __         __
-- |_     _|__|  |_|  |.-----.|  |--.---.-.----.
--   |   | |  |   _|  ||  -__||  _  |  _  |   _|
--   |___| |__|____|__||_____||_____|___._|__|

-- -------------------------------------------------------------------------- --

local function make_button(txt, onclick)
  return function(c)
    local btn = wibox.widget({
      {
        {
          {
            image = gears.color.recolor_image(txt, beautiful.fg_normal),
            resize = true,
            align = "center",
            valign = "center",
            widget = wibox.widget.imagebox,
          },
          left = dpi(3),
          right = dpi(3),
          top = dpi(3),
          bottom = dpi(3),
          widget = wibox.container.margin,
        },
        layout = wibox.layout.fixed.horizontal,
      },
      shape = utilities.graphics.mkroundedrect(2),
      border_width = dpi(1),
      border_color = beautiful.black .. "ee",
      bg = beautiful.btn_back,
      widget = wibox.container.background,
    })

    btn:connect_signal("mouse::enter", function()
      btn.bg =
        beautiful.btn_back_focus, btn:emit_signal("widget::redraw_needed")
    end)

    btn:connect_signal("mouse::leave", function()
      btn.bg = beautiful.btn_back, btn:emit_signal("widget::redraw_needed")
    end)

    btn:add_button(awful.button({}, 1, function()
      if onclick then
        onclick(c)
      end
    end))

    return btn
  end
end

local close_button = make_button(icons.close, function(c)
  c:kill()
end)

local maximize_button = make_button(icons.maximize, function(c)
  c.maximized = not c.maximized
end)

local minimize_button = make_button(icons.minus, function(c)
  gears.timer.delayed_call(function()
    c.minimized = true
  end)
end)

client.connect_signal("request::titlebars", function(c)
  --   if c.requests_no_titlebar then
  --       return
  --   end

  local titlebar = awful.titlebar(c, { position = "top", size = dpi(26) })

  local titlebars_buttons = {
    awful.button({}, 1, function()
      c:activate({ context = "titlebar", action = "mouse_move" })
    end),
    awful.button({}, 3, function()
      c:activate({ context = "titlebar", action = "mouse_resize" })
    end),
  }

  local buttons_loader = {
    layout = wibox.layout.fixed.horizontal,
  }

  titlebar:setup({
    {
      { -- Left
        {

          wibox.widget.base.make_widget(awful.titlebar.widget.iconwidget(c)),
          buttons = titlebars_buttons,
          layout = wibox.layout.fixed.horizontal,
          clip_shape = utilities.graphics.mkroundedrect(6),
        },
        widget = wibox.container.margin,
        right = dpi(2),
        left = dpi(12),
        top = dpi(2),
        bottom = dpi(2),
      },
      { -- Title
        wibox.widget.base.make_widget(awful.titlebar.widget.titlewidget(c)),
        buttons = titlebars_buttons,
        widget = wibox.container.place,
      },
      { -- Right
        {
          minimize_button(c),
          maximize_button(c),
          close_button(c),
          layout = wibox.layout.fixed.horizontal,
          spacing = dpi(6),
        },
        widget = wibox.container.margin,
        left = dpi(6),
        right = dpi(12),
        top = dpi(4),
        bottom = dpi(4),
      },
      layout = wibox.layout.align.horizontal,
    },
    widget = wibox.container.background,
  })
end)
