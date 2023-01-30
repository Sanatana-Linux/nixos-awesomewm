local wibox = require('wibox')
local beautiful = require('beautiful')
local awful = require('awful')
local gears = require('gears')


local dimensions = require('ui.dashboard.dimensions')
local sliders = require('ui.dashboard.modules.settings.sliders')

local full_scr = wibox.widget {
  {
    {
      markup = '',
      font = beautiful.nerd_font .. ' 56',
      align = 'center',
      valign = 'center',
      widget = wibox.widget.textbox,
    },
    left = dimensions.spacing * 3,
    right = dimensions.spacing * 3,
    widget = wibox.container.margin,
  },
  bg = beautiful.bg_lighter,
  border_color = beautiful.grey,
  border_width = 0.75,
  shape = utilities.mkroundedrect(14),
  widget = wibox.container.background,
}

utilities.add_hover(full_scr, beautiful.bg_lighter, beautiful.dimblack)

full_scr:add_button(awful.button({}, 1, function ()
  awesome.emit_signal('dashboard::toggle')
  utilities.screenshot.full { notify = true }
end))

local area_scr = wibox.widget {
  {
    {
      markup = '',
      font = beautiful.nerd_font .. ' 56',
      align = 'center',
      valign = 'center',
      widget = wibox.widget.textbox,
    },
    left = dimensions.spacing * 3,
    right = dimensions.spacing * 3,
    widget = wibox.container.margin,
  },
  bg = beautiful.bg_lighter,
  border_color = beautiful.grey,
  border_width = 0.75,
  shape = utilities.mkroundedrect(14),
  widget = wibox.container.background,
}

utilities.add_hover(area_scr, beautiful.bg_lighter, beautiful.dimblack)

area_scr:add_button(awful.button({}, 1, function ()
  awesome.emit_signal('dashboard::toggle')
  utilities.screenshot.area { notify = true }
end))

local username = wibox.widget.textbox()

username.font = beautiful.font_name .. ' ' .. tostring(tonumber(beautiful.font_size) + 8)
username.align = 'center'

awful.spawn.easy_async('whoami', function (whoami)
  username.markup = 'welcome ' .. utilities.trim(whoami)
end)

local reload = wibox.widget {
  {
    {
      markup = utilities.get_colorized_markup('勒', beautiful.fg_normal),
      font = beautiful.nerd_font .. ' 22',
      align = 'center',
      valign = 'center',
      widget = wibox.widget.textbox,
    },
    left = 11,
    right = 11,
    widget = wibox.container.margin,
  },
  bg = beautiful.dimblack,
  border_color = beautiful.grey,
  border_width = 0.25,
  shape = utilities.mkroundedrect(),
  widget = wibox.container.background,
}

utilities.add_hover(reload, beautiful.dimblack, beautiful.bg_normal)

reload:add_button(awful.button({}, 1, function ()
  awful.spawn('systemctl reboot')
end))

local poweroff = wibox.widget {
  {
    {
      markup = utilities.get_colorized_markup('⏻', beautiful.fg_normal),
      font = beautiful.nerd_font .. ' 20',
      align = 'center',
      valign = 'center',
      widget = wibox.widget.textbox,
    },
    left = 11,
    right = 11,
    widget = wibox.container.margin,
  },
  bg = beautiful.dimblack,
  border_color = beautiful.grey,
  border_width = 0.25,
  shape = utilities.mkroundedrect(),
  widget = wibox.container.background,
}

utilities.add_hover(poweroff, beautiful.dimblack, beautiful.bg_normal)

poweroff:add_button(awful.button({}, 1, function ()
  awful.spawn('systemctl poweroff')
end))

local info = wibox.widget {
  {
    nil,
    {
      {
        {
          image = beautiful.pfp,
          halign = 'center',
          valign = 'center',
          forced_height = 94,
          forced_width = 94,
          
          shape = utilities.mkroundedrect(),
          clip_shape = utilities.mkroundedrect(),
          widget = wibox.widget.imagebox,
        },
        username,
        spacing = dimensions.spacing,
        layout = wibox.layout.fixed.vertical,
      },
      top = dimensions.spacing,
      bottom = dimensions.spacing,
      left = dimensions.spacing * 6,
      right = dimensions.spacing * 6,
      widget = wibox.container.margin,
    },
    {
      {
        {
          {
            {
              reload,
              poweroff,
              spacing = 6,
              layout = wibox.layout.fixed.horizontal,
            },
            right = 6,
            widget = wibox.container.margin,
          },
          valign = 'center',
          halign = 'right',
          layout = wibox.container.place,
        },
        top = 6,
        bottom = 6,
        widget = wibox.container.margin,
      },
      bg = beautiful.black,
      widget = wibox.container.background,
    },
    layout = wibox.layout.align.vertical,
  },
  bg = beautiful.bg_lighter,
  border_color = beautiful.grey,
  border_width = 0.5,
  shape = utilities.mkroundedrect(),
  widget = wibox.container.background
}

local core = wibox.widget {
  {
    {
      full_scr,
      area_scr,
      spacing = dimensions.spacing,
      layout = wibox.layout.flex.vertical,
    },
    info,
    spacing = dimensions.spacing,
    layout = wibox.layout.fixed.horizontal,
  },
  {
    sliders,
    left = dimensions.spacing,
    widget = wibox.container.margin
  },
  layout = wibox.layout.align.horizontal
}

return core
