--     _______         __      ______
--    |_     _|.---.-.|  |--. |   __ \.---.-.----.
--      |   |  |  _  ||  _  | |   __ <|  _  |   _|
--      |___|  |___._||_____| |______/|___._|__|
--   +---------------------------------------------------------------+
-- NOTE: Thanks again to our friends at bling, this is a stripped down version of the pure theme for the tab bar from that widget library which I also took the liberty of commenting out more thoroughly and adapting to my specific needs, which is also explained in comments

--   +---------------------------------------------------------------+
-- Define variables for colors and styles
local bg_normal = beautiful.titlebar_back
local fg_normal = beautiful.lesswhite
local bg_focus = beautiful.titlebar_back_focus
local fg_focus = beautiful.fg_focus
local bg_focus_inactive = beautiful.tabbar_bg_focus_inactive or bg_focus
local fg_focus_inactive = beautiful.tabbar_fg_focus_inactive or fg_focus
local bg_normal_inactive = beautiful.tabbar_bg_normal_inactive or bg_normal
local fg_normal_inactive = beautiful.tabbar_fg_normal_inactive or fg_normal
local font = beautiful.font
local size = dpi(28)
local position = beautiful.tabbar_position or "top"

--   +---------------------------------------------------------------+
-- Create the tabbar widget for a given client
-- NOTE: the tabbar is essentially just a second titlebar and thus is arranged the same way ultimately.
local function create(c, focused_bool, buttons)
  local bg_temp, fg_temp
  if focused_bool then
    bg_temp = bg_focus
    fg_temp = fg_focus
  else
    bg_temp = bg_normal
    fg_temp = fg_normal
  end

  local wid_temp = wibox.widget({
    {
      { -- Left
        wibox.widget.base.make_widget(awful.titlebar.widget.iconwidget(c)),
        buttons = buttons,
        layout = wibox.layout.fixed.horizontal,
      },
      { -- Title
        wibox.widget.base.make_widget(awful.titlebar.widget.titlewidget(c)),
        buttons = buttons,
        widget = wibox.container.place,
      },
      { -- Right
        nil, -- I have no need for buttons I have already on the titlebar here, so nil to keep the layout in order
        layout = wibox.layout.fixed.horizontal,
      },
      layout = wibox.layout.align.horizontal,
    },
    bg = bg_temp,
    fg = fg_temp,
    widget = wibox.container.background,
  })

  return wid_temp
end

-- Return the configuration table
return {
  layout = wibox.layout.flex.horizontal,
  create = create,
  position = position,
  size = size,
  bg_normal = bg_normal,
  bg_focus = bg_focus,
}
