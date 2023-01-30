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
local icons_path = assets_path .. "icons/"
local shapes_path = assets_path .. "shapes/"
local scheme = require("themes.scheme")
-- -------------------------------------------------------------------------- --
-- ---------------------------------- Theme --------------------------------- --
-- -------------------------------------------------------------------------- --
local theme = {}
-- -------------------------------------------------------------------------- --
-- fonts
theme.font_name = 'SF Pro Rounded Heavy '
theme.nerd_font = 'SFMono Bold Nerd Font Complete Mono '
theme.material_icons = 'Material Icons '

theme.font_size = '10'
theme.font = theme.font_name .. ' ' .. theme.font_size
-- --------------------------------- Colors --------------------------------- --
-- base colors
theme.black = scheme.colorD
theme.dimblack = scheme.colorE
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
theme.bg_normal     = scheme.colorB
theme.bg_contrast   = scheme.colorA
theme.bg_lighter    = scheme.colorC
-- -------------------------------------------------------------------------- --
-- elements bg
theme.bg_focus      = theme.dimblack
theme.bg_urgent     = theme.red
theme.bg_minimize   = theme.light_black
theme.bg_systray    = theme.dimblack
-- -------------------------------------------------------------------------- --
-- foregrounds
theme.fg_normal     = scheme.lesswhite
theme.lesswhite     = scheme.lesswhite
theme.fg_focus      = scheme.white
theme.fg_urgent     = scheme.white
theme.fg_minimize   = theme.fg_normal
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
theme.bar_height = 35
-- -------------------------------------------------------------------------- --
-- gaps and borders
theme.useless_gap         = dpi(4)
theme.border_width        = dpi(0)
theme.border_color_normal = theme.bg_normal
theme.border_color_active = theme.bg_focus
theme.border_color_marked = theme.bg_normal
theme.border_radius = 16
-- -------------------------------------------------------------------------- --
-- tasklist
theme.tasklist_plain_task_name = true
theme.tasklist_bg = theme.bg_normal
theme.tasklist_bg_focus = theme.bg_focus
theme.tasklist_bg_urgent = theme.red .. '4D' -- 30% of transparency
-- -------------------------------------------------------------------------- --
-- taglist
theme.taglist_bg = theme.bg_normal
theme.taglist_bg_urgent = theme.taglist_bg
theme.taglist_bg_focus = theme.bg_focus
theme.taglist_font = theme.material_icons .. ' 13'

-- -------------------------------------------------------------------------- --
-- menu
theme.menu_font = theme.font
theme.menu_submenu_icon = gears.color.recolor_image(shapes_path .. "triangle.png", theme.fg_normal)
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
theme.wallpaper = assets_path .. "wallpaper.png"
-- -------------------------------------------------------------------------- --
-- ---------------------------------- Icons --------------------------------- --
-- layouts
theme.layout_fairh = gears.color.recolor_image(themes_path.."default/layouts/fairhw.png", theme.fg_normal)
theme.layout_fairv = gears.color.recolor_image(themes_path.."default/layouts/fairvw.png", theme.fg_normal)
theme.layout_floating  = gears.color.recolor_image(themes_path.."default/layouts/floatingw.png", theme.fg_normal)
theme.layout_magnifier = gears.color.recolor_image(themes_path.."default/layouts/magnifierw.png", theme.fg_normal)
theme.layout_max = gears.color.recolor_image(themes_path.."default/layouts/maxw.png", theme.fg_normal)
theme.layout_fullscreen = gears.color.recolor_image(themes_path.."default/layouts/fullscreenw.png", theme.fg_normal)
theme.layout_tilebottom = gears.color.recolor_image(themes_path.."default/layouts/tilebottomw.png", theme.fg_normal)
theme.layout_tileleft   = gears.color.recolor_image(themes_path.."default/layouts/tileleftw.png", theme.fg_normal)
theme.layout_tile = gears.color.recolor_image(themes_path.."default/layouts/tilew.png", theme.fg_normal)
theme.layout_tiletop = gears.color.recolor_image(themes_path.."default/layouts/tiletopw.png", theme.fg_normal)
theme.layout_spiral  = gears.color.recolor_image(themes_path.."default/layouts/spiralw.png", theme.fg_normal)
theme.layout_dwindle = gears.color.recolor_image(themes_path.."default/layouts/dwindlew.png", theme.fg_normal)
theme.layout_cornernw = gears.color.recolor_image(themes_path.."default/layouts/cornernww.png", theme.fg_normal)
theme.layout_cornerne = gears.color.recolor_image(themes_path.."default/layouts/cornernew.png", theme.fg_normal)
theme.layout_cornersw = gears.color.recolor_image(themes_path.."default/layouts/cornersww.png", theme.fg_normal)
theme.layout_cornerse = gears.color.recolor_image(themes_path.."default/layouts/cornersew.png", theme.fg_normal)
theme.layout_centermaster = gears.color.recolor_image(assets_path .. '/layouts/centermaster.png', theme.fg_normal)
theme.layout_stackLeft = gears.color.recolor_image(assets_path .. '/layouts/stack_left.png', theme.fg_normal)
theme.layout_stack = gears.color.recolor_image(assets_path .. '/layouts/stack.png', theme.fg_normal)
theme.layout_empathy = gears.color.recolor_image(assets_path .. '/layouts/empathy.png', theme.fg_normal)
theme.layout_floating = gears.color.recolor_image(assets_path .. '/layouts/floating.png', theme.fg_normal)
theme.layout_thrizen = gears.color.recolor_image(assets_path .. '/layouts/thrizen.png', theme.fg_normal)
theme.layout_horizon = gears.color.recolor_image(assets_path .. '/layouts/horizon.png', theme.fg_normal)
theme.layout_equalarea = gears.color.recolor_image(assets_path .. '/layouts/equalarea.png', theme.fg_normal)
theme.layout_deck = gears.color.recolor_image(assets_path .. '/layouts/deck.png', theme.fg_normal)
-- -------------------------------------------------------------------------- --
-- other icons
theme.launcher_icon = assets_path .. "launcher.png"
theme.menu_icon = gears.color.recolor_image(icons_path .. "menu.svg", theme.fg_normal)
theme.hints_icon = gears.color.recolor_image(icons_path .. "hints.svg", theme.blue)
theme.powerbutton_icon = gears.color.recolor_image(icons_path .. "poweroff.svg", theme.red)
theme.poweroff_icon = icons_path .. 'poweroff.svg'
-- -------------------------------------------------------------------------- --
-- volume 
theme.volume_on = gears.color.recolor_image(icons_path .. 'volume-on.svg', theme.fg_normal)
theme.volume_muted = gears.color.recolor_image(icons_path .. 'volume-muted.svg', theme.fg_normal)
-- -------------------------------------------------------------------------- --
-- network
theme.network_connected = ''
theme.network_disconnected = '睊'
-- -------------------------------------------------------------------------- --
-- pfp
theme.pfp = assets_path .. 'pfp.png'
-- -------------------------------------------------------------------------- --
-- fallback music
theme.fallback_music = assets_path .. 'fallback-music.png'
-- -------------------------------------------------------------------------- --
-- fallback notification icon
theme.fallback_notif_icon = gears.color.recolor_image(icons_path .. 'hints.svg', theme.blue)
-- -------------------------------------------------------------------------- --
-- icon theme
theme.icon_theme = "Papirus-Dark"
-- -------------------------------------------------------------------------- --
-- task preview
theme.task_preview_widget_border_radius = dpi(7)
theme.task_preview_widget_bg = theme.bg_normal
theme.task_preview_widget_border_color = theme.bg_normal
theme.task_preview_widget_border_width = 0
theme.task_preview_widget_margin = dpi(10)
-- -------------------------------------------------------------------------- --
-- tag preview
theme.tag_preview_widget_border_radius = dpi(7)
theme.tag_preview_client_border_radius = dpi(7)
theme.tag_preview_client_opacity = 0.5
theme.tag_preview_client_bg = theme.bg_lighter
theme.tag_preview_client_border_color = theme.blue
theme.tag_preview_client_border_width = 1
theme.tag_preview_widget_bg = theme.bg_normal
theme.tag_preview_widget_border_color = theme.bg_normal
theme.tag_preview_widget_border_width = 0
theme.tag_preview_widget_margin = dpi(7)
-- -------------------------------------------------------------------------- --
-- tooltip
theme.tooltip_bg = theme.bg_normal
theme.tooltip_fg = theme.fg_normal

theme.chart_arc = "radial:0,0,0:360,360,360:0,".. scheme.colorW .. ":0.5,".. scheme.colorZ..":1," .. scheme.color1


return theme
