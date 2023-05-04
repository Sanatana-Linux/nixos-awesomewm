--  _____                           __               
-- |     |_.---.-.--.--.-----.----.|  |--.-----.----.
-- |       |  _  |  |  |     |  __||     |  -__|   _|
-- |_______|___._|_____|__|__|____||__|__|_____|__|  
-- -------------------------------------------------------------------------- --
local app_menu = require("ui.bar.popups.app_menu")
-- -------------------------------------------------------------------------- --
-- NOTE: Provides implementation arguments for custom app_launcher implementation (forked from Bling's app_launcher originally)
-- NOTE: This is initialized by ui/init.lua, which is why this file is located here (for now)
-- 
local args = {
  sort_alphabetically = true,
  save_history = true,
  favorites = {
    "firefox",
    "caja",
		"gimp",
		"inkscape",
    "krita",
    "code"
  },
  search_commands = true,
  hide_on_right_clicked_outside = true,

  border_width = 0,
  placement = function(d)
    awful.placement.bottom_left(d, {honor_workarea = true, margins = 12})
  end,

  background = beautiful.bg_normal,
	type = "dock",
  skip_empty_icons = false,
  expand_apps = false,
  shape= utilities.mkroundedrect(6),

  prompt_height = 45,
  prompt_margins = 10,
  prompt_paddings = 10,
  prompt_icon_text_spacing = 10,
  prompt_text_valign = "center",
  prompt_text = "Search: ",
  prompt_icon = "",
  prompt_icon_font = beautiful.nerd_font,
  prompt_color = beautiful.bg_lighter,
  prompt_cursor_color = beautiful.fg_normal,
  prompt_text_color = beautiful.fg_normal,
  prompt_icon_color = beautiful.fg_normal,
  prompt_font = beautiful.nerd_font,
  prompt_border_color = beautiful.lessgrey .. '66',
  prompt_border_width = dpi(0.75),
  prompt_shape = utilities.mkroundedrect(), 

  




  app_name_font = beautiful.nerd_font,

app_border_color = beautiful.lessgrey .. '66',
  app_selected_color = beautiful.bg_normal,
  app_selected_hover_color = beautiful.bg_normal,
  app_normal_color = beautiful.bg_lighter,

  app_normal_hover_color = beautiful.bg_normal,
  app_name_selected_color = beautiful.lessgrey,
  apps_per_column = 1,
  apps_per_row = 7,
  app_width = dpi(300),
  app_height = dpi(50),
  apps_margin = {top = 0, left = dpi(0), right = 0, bottom = 0},
  apps_spacing = 0,
	app_content_padding = {top = 0, left = dpi(8), right = 0, bottom = 0},
	app_content_spacing = dpi(10),
  app_show_icon = true,
	app_icon_width = dpi(36),
	app_icon_height = dpi(36),
	app_icon_halign = "left",
  app_name_halign = "center"
}

local app_launcher = app_menu.widget.app_launcher(args)

awesome.connect_signal("signal::launcher", function()
  app_launcher:toggle()
end)
