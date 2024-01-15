--------------------------------------------------------------------------- --
-- ------------------------------ Dependencies ------------------------------ --
-- -------------------------------------------------------------------------- --
local xresources = require("beautiful.xresources")
local gears = require("gears")
local gfs = require("gears.filesystem")
local dpi = xresources.apply_dpi

-- -------------------------------------------------------------------------- --
-- paths
local themes_path = gfs.get_themes_dir()
local assets_path = gfs.get_configuration_dir() .. "themes/assets/"
-- -------------------------------------------------------------------------- --
-- assets
local icons_path = assets_path .. "icons/svg/"
local shapes_path = assets_path .. "shapes/"
local scheme = require("themes.scheme")

local icon = require("themes.assets.icons")
-- -------------------------------------------------------------------------- --
-- ---------------------------------- Theme --------------------------------- --
-- -------------------------------------------------------------------------- --
local theme = {}
-- -------------------------------------------------------------------------- --
-- fonts
theme.font_name = "Rounded Mplus 1c ExtraBold "
theme.nerd_font = "M+1Code Nerd Font Bold "
theme.title_font = "Rounded Mplus 1c ExtraBold "
theme.material_icons = "Font Awesome 5 Free  "
theme.font_size = "10"
theme.font = theme.font_name .. " " .. theme.font_size
-- --------------------------------- Colors --------------------------------- --
-- base colors
theme.black = scheme.black
theme.dimblack = scheme.colorD
theme.light_black = scheme.colorF
theme.dark_grey = scheme.colorH
theme.grey = scheme.colorR
theme.light_grey = scheme.colorX
theme.lessgrey = scheme.color1
theme.accent = scheme.color1
theme.red = scheme.color16
theme.yellow = scheme.color18
theme.magenta = scheme.color13
theme.green = scheme.color17
theme.blue = scheme.color19
theme.cyan = scheme.color7
theme.aqua = scheme.color21

-- -------------------------------------------------------------------------- --
-- backgrounds
theme.bg_normal = scheme.bg_normal
theme.background = theme.bg_normal
theme.bg_contrast = scheme.bg_contrast
theme.background_alt = theme.bg_contrast
theme.bg_lighter = scheme.bg_lighter
theme.bg_darkest = scheme.bg_darkest
theme.bg_focus = scheme.bg_focus
theme.dimblacker = scheme.colorR
theme.bg_urgent = scheme.alpha(theme.red, "88")
theme.bg_minimize = theme.bg_lighter
theme.bg_systray = theme.bg_focus

theme.widget_back =
  "linear:180,0:32,180:0,#3c3c3c88:0.25,#55555588:0.5,#71717188:0.75,#66666688:1,#44444488"

theme.widget_back_focus =
  "linear:180,0:23,180:0,#666666aa:0.25,#5c5c5caa:0.4,#555555dd:0.5,#3c3c3caa:0.6,#5c5c5cdd:0.75, #666666aa:1,#717171aa"

theme.titlebar_back =
  "linear:180,0:32,180:0,#1c1c1caa:0.25,#222222aa:0.5,#2c2c2caa:0.75,#222222aa:1,#1c1c1caa"

theme.titlebar_back_focus =
  "linear:180,0:23,180:0,#3c3c3caa:0.25,#222222aa:0.5,#2c2c2caa:0.75,#1c1c1caa:1,#333333aa"

theme.widget_back_focus_tag =
  "linear:180,0:0,180:0,#666666dd:0.25,#888888dd:0.4,#777777dd:0.5,#555555aa:0.6,#4c4c4cdd:0.75, #444444aa:1,#333333aa"

theme.widget_back_tag =
  "linear:180,0:32,180:0,#888888dd:0.25,#717171dd:0.5,#666666dd:0.75,#555555dd:1,#4c4c4cdd"

theme.appmenu_back = "linear:0,0:180,180:0,"
  .. scheme.colorB
  .. ":1,"
  .. scheme.colorR

theme.btn_back =
  "radial:50,50:50,50:50,#555555aa:0.25,#5c5c5caa:0.5,#6c6c6caa:0.75,#d7d7d7AA:1,#e6e6e6AA"
theme.btn_back_focus =
  "radial:50,50:50,50:50,#8c8c8caa:0.25,#7c7c7caa:0.5,#6c6c6caa:0.75,#5c5c5caa:1,#555555aa"
-- -------------------------------------------------------------------------- --
-- foregrounds
theme.fg_normal = scheme.white
theme.white = scheme.white
theme.lesswhite = scheme.alt_white
theme.fg_focus = scheme.white
theme.fg_urgent = scheme.white
theme.fg_minimize = theme.fg_normal
-- -------------------------------------------------------------------------- --
-- some actions bg colors
theme.actions = {
  bg = theme.bg_normal,
  contrast = theme.bg_contrast,
  lighter = theme.bg_lighter,
  fg = theme.fg_normal,
}
-- ----------------------------- Theme Variables ---------------------------- --
-- bar
theme.bar_height = dpi(42)
-- -------------------------------------------------------------------------- --
-- titlebar
theme.titlebar_bg_normal = theme.titlebar_back
theme.titlebar_fg_normal = theme.fg_normal
theme.titlebar_bg_focus = theme.titlebar_back_focus
theme.titlebar_fg_focus = theme.fg_focus

--   +---------------------------------------------------------------+
-- gaps and borders
theme.useless_gap = dpi(4)
theme.border_width = dpi(0)
theme.border_color_normal = theme.bg_normal
theme.border_color_active = theme.bg_focus
theme.border_color_marked = theme.bg_normal
theme.border_radius = dpi(8)
-- -------------------------------------------------------------------------- --
-- tasklist
theme.tasklist_plain_task_name = true
theme.tasklist_bg = theme.bg_normal
theme.tasklist_bg_focus = theme.bg_focus
theme.tasklist_bg_urgent = theme.red .. "4D" -- 30% of transparency

-- -------------------------------------------------------------------------- --
-- taglist
theme.taglist_bg = theme.widget_back_tag
theme.taglist_bg_empty = theme.widget_back_tag
theme.taglist_bg_focus = theme.widget_back_focus_tag
theme.taglist_bg_occupied = theme.widget_back

theme.taglist_font = "awesomewm-font Regular 13"
theme.taglist_shape = require("utilities.widgets.mkroundedrect")()
theme.taglist_spacing = dpi(5)
theme.taglist_shape_border_color = theme.grey .. "cc"
theme.taglist_shape_border_width = dpi(1)
-- -------------------------------------------------------------------------- --
-- menu
theme.menu_font = theme.nerd_font .. " 12"
theme.menu_submenu_icon =
  gears.color.recolor_image(shapes_path .. "triangle.png", theme.fg_normal)
theme.menu_height = dpi(40)
theme.menu_width = dpi(180)
theme.menu_bg_focus = theme.bg_lighter
theme.menu_bg_normal = theme.bg_normal .. "99"
-- -------------------------------------------------------------------------- --
-- wallpaper
theme.wallpaper = assets_path .. "wallpaper2.png"
-- -------------------------------------------------------------------------- --
-- ---------------------------------- Icons --------------------------------- --
-- layouts
theme.layout_fairh = gears.color.recolor_image(
  themes_path .. "default/layouts/fairhw.png",
  theme.fg_normal
)
theme.layout_fairv = gears.color.recolor_image(
  themes_path .. "default/layouts/fairvw.png",
  theme.fg_normal
)
theme.layout_floating = gears.color.recolor_image(
  themes_path .. "default/layouts/floatingw.png",
  theme.fg_normal
)
theme.layout_magnifier = gears.color.recolor_image(
  themes_path .. "default/layouts/magnifierw.png",
  theme.fg_normal
)
theme.layout_max = gears.color.recolor_image(
  themes_path .. "default/layouts/maxw.png",
  theme.fg_normal
)
theme.layout_fullscreen = gears.color.recolor_image(
  themes_path .. "default/layouts/fullscreenw.png",
  theme.fg_normal
)
theme.layout_tilebottom = gears.color.recolor_image(
  themes_path .. "default/layouts/tilebottomw.png",
  theme.fg_normal
)
theme.layout_tileleft = gears.color.recolor_image(
  themes_path .. "default/layouts/tileleftw.png",
  theme.fg_normal
)
theme.layout_tile = gears.color.recolor_image(
  themes_path .. "default/layouts/tilew.png",
  theme.fg_normal
)
theme.layout_tiletop = gears.color.recolor_image(
  themes_path .. "default/layouts/tiletopw.png",
  theme.fg_normal
)
theme.layout_spiral = gears.color.recolor_image(
  themes_path .. "default/layouts/spiralw.png",
  theme.fg_normal
)
theme.layout_dwindle = gears.color.recolor_image(
  themes_path .. "default/layouts/dwindlew.png",
  theme.fg_normal
)
theme.layout_cornernw = gears.color.recolor_image(
  themes_path .. "default/layouts/cornernww.png",
  theme.fg_normal
)
theme.layout_cornerne = gears.color.recolor_image(
  themes_path .. "default/layouts/cornernew.png",
  theme.fg_normal
)
theme.layout_cornersw = gears.color.recolor_image(
  themes_path .. "default/layouts/cornersww.png",
  theme.fg_normal
)
theme.layout_cornerse = gears.color.recolor_image(
  themes_path .. "default/layouts/cornersew.png",
  theme.fg_normal
)
theme.layout_center = gears.color.recolor_image(
  assets_path .. "/layouts/centermaster.png",
  theme.fg_normal
)
theme.layout_stackLeft = gears.color.recolor_image(
  assets_path .. "/layouts/stack_left.png",
  theme.fg_normal
)
theme.layout_stack = gears.color.recolor_image(
  assets_path .. "/layouts/stack.png",
  theme.fg_normal
)
theme.layout_cascade = gears.color.recolor_image(
  assets_path .. "/layouts/cascade.png",
  theme.fg_normal
)
theme.layout_cascadetile = gears.color.recolor_image(
  assets_path .. "/layouts/cascadetile.png",
  theme.fg_normal
)
theme.layout_empathy = gears.color.recolor_image(
  assets_path .. "/layouts/empathy.png",
  theme.fg_normal
)
theme.layout_floating = gears.color.recolor_image(
  assets_path .. "/layouts/floating.png",
  theme.fg_normal
)
theme.layout_thrizen = gears.color.recolor_image(
  assets_path .. "/layouts/thrizen.png",
  theme.fg_normal
)
theme.layout_horizon = gears.color.recolor_image(
  assets_path .. "/layouts/horizon.png",
  theme.fg_normal
)
theme.layout_equalarea = gears.color.recolor_image(
  assets_path .. "/layouts/equalarea.png",
  theme.fg_normal
)
theme.layout_deck =
  gears.color.recolor_image(assets_path .. "/layouts/deck.png", theme.fg_normal)
theme.layout_overflow =
  gears.color.recolor_image(assets_path .. "/layouts/deck.png", theme.fg_normal)
theme.layout_mstab = gears.color.recolor_image(
  assets_path .. "/layouts/mstab.png",
  theme.fg_normal
)
-- -------------------------------------------------------------------------- --
-- other icons
--
theme.icon_theme = "Papirus-Dark"

theme.chart_arc = "radial:0,0,0:360,360,360:0,"
  .. scheme.colorW
  .. ":0.5,"
  .. scheme.colorZ
  .. ":1,"
  .. scheme.color1

return theme
