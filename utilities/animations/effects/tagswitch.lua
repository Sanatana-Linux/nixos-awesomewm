
-- DPI
dpi = beautiful.xresources.apply_dpi1
 
local M = wibox {
  visible = false,
  opacity = 0,
  bg      =  beautiful.bg_normal .. '33',
  fg      =  beautiful.fg_normal,
  ontop   = true,
  height  = 90,
  width   = 90,
}
 
M:setup {
  {
    id     = "text",
    markup = "<b>dev</b>",
    font   = beautiful.title_font .. '36',
    widget = wibox.widget.textbox,
  },
  valign = "center",
  halign = "center",
  layout = wibox.container.place,
}
 
awful.placement.centered(M, { parent = awful.screen.focused() })
 
M.changeText = function (text)
  M:get_children_by_id("text")[1]:set_markup("<b>" .. text .. "</b>")
end
 
M.animate = function (text)
  M.changeText(text)
  fade(M, 200,  0.5)
end
 
return M