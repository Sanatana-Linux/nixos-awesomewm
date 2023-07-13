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
theme.font_name = "Oxanium Semi-Bold  "
theme.nerd_font = "Agave Nerd Font Mono Bold "
theme.title_font = "Oxanium Ultra-Bold "
theme.material_icons = "Font Awesome 5 Free s"
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
theme.lessgrey = scheme.colorZ
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
"linear:180,0:0,121:0,#28282899:0.25,#44444499:0.5,#717171cc:0.75,#55555599:1,#2C2C2C99"

theme.widget_back_focus =
"linear:180,0:0,180:0,#666666aa:0.25,#5c5c5caa:0.4,#555555dd:0.5,#3c3c3caa:0.6,#5c5c5cdd:0.75, #666666aa:1,#717171aa"

theme.widget_back_focus_tag =
"linear:180,0:0,180:0,#666666aa:0.25,#5c5c5caa:0.4,#555555dd:0.5,#3c3c3caa:0.6,#5c5c5cdd:0.75, #666666aa:1,#717171aa"
theme.widget_back_tag = "linear:63,0:0,21:0,"
    .. scheme.colorM
    .. ":1,"
    .. scheme.colorR

theme.appmenu_back = "linear:180,0:0,121:0,"
    .. scheme.colorB
    .. ":1,"
    .. scheme.colorR
-- -------------------------------------------------------------------------- --
-- foregrounds
theme.fg_normal = scheme.white
theme.white = scheme.white
theme.lesswhite = scheme.lesswhite
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
theme.bar_height = dpi(48)
-- -------------------------------------------------------------------------- --
-- gaps and borders
theme.useless_gap = dpi(4)
theme.border_width = dpi(0)
theme.border_color_normal = theme.bg_normal
theme.border_color_active = theme.bg_focus
theme.border_color_marked = theme.bg_normal
theme.border_radius = 16
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

theme.taglist_font = theme.title_font .. " 11"
theme.taglist_shape = require("utilities.widgets.mkroundedrect")()
theme.taglist_spacing = dpi(5)
theme.taglist_shape_border_color = theme.grey .. "cc"
theme.taglist_shape_border_width = dpi(1)
-- -------------------------------------------------------------------------- --
-- menu
theme.menu_font = theme.font
theme.menu_submenu_icon =
    gears.color.recolor_image(shapes_path .. "triangle.png", theme.fg_normal)
theme.menu_height = dpi(40)
theme.menu_width = dpi(180)
theme.menu_bg_focus = theme.bg_lighter
-- -------------------------------------------------------------------------- --
-- titlebar
theme.titlebar_bg = theme.light_black
theme.titlebar_bg_focus = theme.black
theme.titlebar_fg = theme.fg_normal

-- -------------------------------------------------------------------------- --
-- wallpaper
theme.wallpaper = assets_path .. "wallpaper6.jpg"
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
theme.layout_deck = gears.color.recolor_image(
  assets_path .. "/layouts/deck.png",
  theme.fg_normal
)
theme.layout_overflow = gears.color.recolor_image(
  assets_path .. "/layouts/deck.png",
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
