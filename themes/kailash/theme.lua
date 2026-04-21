local beautiful = require("beautiful")
local gfs = require("gears.filesystem")
local gshape = require("gears.shape")
local gcolor = require("gears.color")
local dpi = beautiful.xresources.apply_dpi

local theme_name = "kailash"
local theme_path = gfs.get_configuration_dir()
    .. "/themes/"
    .. theme_name
    .. "/"
local icons_path = theme_path .. "icons/"

local theme = {}

-- Icon theme configuration for consistent icon lookup across all components
theme.icon_theme = "Colloid-Dark"

theme.font_name = "OperatorUltraNerdFontComplete Nerd Font Propo "
theme.taglist_font = "awesomewm-font 10"
theme.font = theme.font_name .. tostring(dpi(13))

-- Text icons (Nerd Font icons)
theme.text_icons = {
    arrow_down = "",
    arrow_left = "",
    arrow_right = "",
    arrow_up = "",
    bell_off = "",
    bell_on = "",
    bluetooth = "",
    bluetooth_off = "",
    calendar = "",
    check = "",
    check_off = "",
    check_on = "",
    cloud = "",
    cross = "",
    dash = "",
    exit = "",
    eye_off = "",
    eye_on = "",
    gear = "",
    home = "",
    image = "",
    lock = "",
    lock_off = "",
    lock_on = "",
    menu = "",
    mic_off = "",
    mic_on = "",
    mist = "",
    poweroff = "",
    reboot = "",
    search = "",
    shrink = "",
    sliders = "",
    snow = "",
    stretch = "",
    sun = "",
    switch_off = "",
    switch_on = "",
    thermometer = "",
    thunder = "",
    trash = "",
    vol_off = "",
    vol_on = "",
    wait = "",
    wifi = "",
    wind = "",
    bolt = "",
}

-- Colors
theme.red = "#fc618d"
theme.green = "#7bd88f"
theme.yellow = "#Fce566"
theme.blue = "#6b9ce8"
theme.magenta = "#948ae3"
theme.cyan = "#5ad4e6"
theme.orange = "#fd9353"

theme.bg = "#1f1f1F"
theme.bg_alt = "#2a2a2A"
theme.bg_urg = "#30303c"

-- Backdrop for popups (blur matching picom: dual_kawase, strength 6)
theme.backdrop_color = "#00000080"

theme.fg_alt = "#8c8c98"
theme.fg = "#f7f1ff"

theme.ac = "#5f5f6a"
theme.rounded = true

-- Corner radius (matching picom: corner-radius = 12)
theme.border_width = dpi(1)
theme.border_radius = dpi(12)
theme.separator_thickness = dpi(1)
theme.useless_gap = dpi(5)

-- Shadow settings (matching picom: shadow-radius = 8, shadow-opacity = 0.6)
theme.shadow_radius = 8
theme.shadow_opacity = 0.6
theme.shadow_offset_x = 12
theme.shadow_offset_y = 12

-- Window opacity settings (matching picom: inactive-opacity = 0.90, active-opacity = 1.0)
theme.inactive_opacity = 0.90
theme.active_opacity = 1.0
theme.frame_opacity = 0.9

-- Focus/opacity exclusions
theme.focus_exclude = {}

theme.separator_color = theme.bg_urg
theme.bg_normal = theme.bg
theme.fg_normal = theme.fg

-- Gradient definitions
theme.bg_gradient = "radial:0,21:0,56:0," .. "#4c4c4ccc" .. ":1," .. "#111111cc"
theme.bg_gradient_alt = "radial:0,510:0,16:0,"
    .. "#2c2c2ccc"
    .. ":1,"
    .. "#0c0c0ccc"
theme.bg_gradient_titlebar = theme.bg .. "99"
theme.bg_gradient_titlebar_alt = theme.bg .. "99"
theme.bg_gradient_button = "linear:0,0:0,32:0,"
    .. "#5f5f5fcc"
    .. ":1,"
    .. "#2c2c2ccc"
theme.bg_gradient_button_alt = "linear:0,0:0,21:0,"
    .. "#4c4c4ccc"
    .. ":1,"
    .. "#6a6a6acc"
theme.bg_gradient_panel = "linear:0,0:0,21:0,"
    .. "#323232cc"
    .. ":1,"
    .. "#222222cc"
theme.bg_gradient_recessed = "linear:0,0:0,21:0,"
    .. "#292929cc"
    .. ":1,"
    .. "#4a4a4acc"

-- -------------------------------------------------------------------------- --
-- tasklist

theme.tasklist_bg_normal = theme.bg_gradient
theme.tasklist_bg_focus = theme.bg_gradient_alt

theme.tasklist_bg_minimize = theme.bg_gradient_titlebar_alt

-- -------------------------------------------------------------------------- --
-- titlebar

theme.border_color_normal = "#00000000"
theme.border_color_active = "#55555555"

theme.titlebar_bg_normal = theme.bg_alt .. "99"
theme.titlebar_bg_focus = theme.bg .. "99"
theme.titlebar_bg_urgent = theme.bg_urg .. "99"
theme.titlebar_fg_normal = theme.fg_alt
theme.titlebar_fg_focus = theme.fg
theme.titlebar_fg_urgent = theme.red

theme.tab_bar_margin_height = dpi(3)

theme.notification_margins = dpi(30)
theme.notification_spacing = dpi(10)
theme.notification_timeout = 5

-- Notification action button styles (for screenshot buttons)
theme.notification_action_bg_normal = theme.bg_gradient_button
theme.notification_action_bg_selected = theme.bg_gradient_button_alt
theme.notification_action_fg_normal = theme.fg
theme.notification_action_fg_selected = theme.fg
theme.notification_action_shape = function(cr, w, h)
    require("gears.shape").rounded_rect(cr, w, h, dpi(6))
end
theme.notification_action_label_only = false
theme.notification_action_margin_horizontal = dpi(8)
theme.notification_action_margin_vertical = dpi(4)

theme.menu_submenu = "» "
theme.menu_bg_normal = theme.bg
theme.menu_fg_normal = theme.fg
theme.menu_bg_focus = theme.ac
theme.menu_fg_focus = theme.bg
theme.menu_border_width = theme.border_width
theme.menu_border_color = theme.border_color

theme.systray_icon_spacing = dpi(6)
theme.bg_systray = theme.bg_gradient_panel
theme.systray_icon_size = dpi(22)
theme.systray_icon_margin = dpi(4)

theme.wallpaper = theme_path .. "wallpaper/wallpaper.png"

theme.layout_fairh =
    gcolor.recolor_image(icons_path .. "/layouts/fairh.svg", theme.fg)
theme.layout_fairv =
    gcolor.recolor_image(icons_path .. "/layouts/fairv.svg", theme.fg)
theme.layout_magnifier =
    gcolor.recolor_image(icons_path .. "/layouts/magnifier.svg", theme.fg)
theme.layout_max =
    gcolor.recolor_image(icons_path .. "/layouts/max.svg", theme.fg)
theme.layout_fullscreen =
    gcolor.recolor_image(icons_path .. "/layouts/fullscreen.svg", theme.fg)
theme.layout_tilebottom =
    gcolor.recolor_image(icons_path .. "/layouts/tilebottom.svg", theme.fg)
theme.layout_tileleft =
    gcolor.recolor_image(icons_path .. "/layouts/tileleft.svg", theme.fg)
theme.layout_tile =
    gcolor.recolor_image(icons_path .. "/layouts/tile.svg", theme.fg)
theme.layout_tiletop =
    gcolor.recolor_image(icons_path .. "/layouts/tiletop.svg", theme.fg)
theme.layout_spiral =
    gcolor.recolor_image(icons_path .. "/layouts/spiral.svg", theme.fg)
theme.layout_dwindle =
    gcolor.recolor_image(icons_path .. "/layouts/dwindle.svg", theme.fg)
theme.layout_cornernw =
    gcolor.recolor_image(icons_path .. "/layouts/cornernw.svg", theme.fg)
theme.layout_cornerne =
    gcolor.recolor_image(icons_path .. "/layouts/cornerne.svg", theme.fg)
theme.layout_cornersw =
    gcolor.recolor_image(icons_path .. "/layouts/cornersw.svg", theme.fg)
theme.layout_cornerse =
    gcolor.recolor_image(icons_path .. "/layouts/cornerse.svg", theme.fg)
theme.layout_center =
    gcolor.recolor_image(icons_path .. "/layouts/centermaster.svg", theme.fg)
theme.layout_stackLeft =
    gcolor.recolor_image(icons_path .. "/layouts/stack_left.svg", theme.fg)
theme.layout_stack =
    gcolor.recolor_image(icons_path .. "/layouts/stack.svg", theme.fg)
theme.layout_cascade =
    gcolor.recolor_image(icons_path .. "/layouts/cascade.svg", theme.fg)
theme.layout_cascadetile =
    gcolor.recolor_image(icons_path .. "/layouts/cascadetile.svg", theme.fg)
theme.layout_floating =
    gcolor.recolor_image(icons_path .. "/layouts/floating.svg", theme.fg)
theme.layout_thrizen =
    gcolor.recolor_image(icons_path .. "/layouts/thrizen.svg", theme.fg)
theme.layout_horizon =
    gcolor.recolor_image(icons_path .. "/layouts/horizon.svg", theme.fg)
theme.layout_equalarea =
    gcolor.recolor_image(icons_path .. "/layouts/equalarea.svg", theme.fg)
theme.layout_deck =
    gcolor.recolor_image(icons_path .. "/layouts/deck.svg", theme.fg)
theme.layout_overflow =
    gcolor.recolor_image(icons_path .. "/layouts/deck.svg", theme.fg)
theme.layout_mstab =
    gcolor.recolor_image(icons_path .. "/layouts/mstab.svg", theme.fg)

return theme
