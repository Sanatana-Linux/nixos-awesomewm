--     _______         __      ______             
--    |_     _|.---.-.|  |--. |   __ \.---.-.----.
--      |   |  |  _  ||  _  | |   __ <|  _  |   _|
--      |___|  |___._||_____| |______/|___._|__|  
--   +---------------------------------------------------------------+
--
-- TODO: remove most of this since I will not need customization options in my own configuration when changing the values as necessary is just as easy

local bg_normal = beautiful.bg_normal
local fg_normal = beautiful.lesswhite
local bg_focus = beautiful.bg_focus
local fg_focus = beautiful.fg_focus
local bg_focus_inactive = beautiful.tabbar_bg_focus_inactive or bg_focus
local fg_focus_inactive = beautiful.tabbar_fg_focus_inactive or fg_focus
local bg_normal_inactive = beautiful.tabbar_bg_normal_inactive or bg_normal
local fg_normal_inactive = beautiful.tabbar_fg_normal_inactive or fg_normal
local font = beautiful.font
local size = beautiful.tabbar_size or 20
local position = beautiful.tabbar_position or "top"

local function create(c, focused_bool, buttons, inactive_bool)
  local bg_temp = inactive_bool and bg_normal_inactive or bg_normal
  local fg_temp = inactive_bool and fg_normal_inactive or fg_normal
  if focused_bool then
    bg_temp = inactive_bool and bg_focus_inactive or bg_focus
    fg_temp = inactive_bool and fg_focus_inactive or fg_focus
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
        -- I have no need for buttons I have already on the titlebar here, so nil to keep the layout in order
        nil,

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

return {
  layout = wibox.layout.flex.horizontal,
  create = create,
  position = position,
  size = size,
  bg_normal = bg_normal,
  bg_focus = bg_focus,
}

