local xresources = require("beautiful.xresources")
local rnotification = require("ruled.notification")
local dpi = xresources.apply_dpi
local gears = require("gears")
local gfs = require("gears.filesystem")
local helpers = require("helpers")
local settings = require("setup").settings
-- Var
local themes_path = gfs.get_configuration_dir() .. "theme/"
local home = os.getenv("HOME")
local assets_path = gfs.get_configuration_dir() .. "theme/assets/"
local theme = {}

local data =
    helpers.readJson(gears.filesystem.get_cache_dir() .. "json/settings.json")

----- User Preferences -----

theme.pfp = data.pfp
---@diagnostic disable-next-line: param-type-mismatch
theme.user = string.gsub(os.getenv("USER"), "^%l", string.upper)
theme.hostname = os.getenv("HOST")
----- Font -----
local themeName = settings.colorscheme
local colors = require("theme.colors." .. themeName)

theme.wallpaper = themes_path .. "walls/" .. colors.name .. ".jpg"
theme.iconThemePath = settings.iconTheme
theme.scheme = themeName
theme.sans = "Ubuntu Nerd Font, Bold "
theme.mono = "M+1Code Nerd Font Bold "
theme.icon = "Font Awesome 16 "
theme.icon_theme = "Reversal"
theme.font = "Ubuntu Nerd Font, Bold  "
theme.prompt_font = "Pixel Code, Bold"
----- General/default Settings -----

theme.bg_normal = colors.bg
theme.bg_focus = colors.mbg
theme.bg_urgent = colors.bg
theme.bg_minimize = colors.mbg
theme.bg_systray = colors.mbg

theme.style = colors.type

theme.fg_normal = colors.fg
theme.fg_focus = theme.fg_normal
theme.fg_urgent = theme.fg_normal
theme.fg_minimize = theme.fg_normal

theme.useless_gap = dpi(tonumber(data.gaps))
theme.border_width = dpi(0)

-- Colors

theme.blue = colors.pri
theme.yellow = colors.warn
theme.green = colors.ok
theme.red = colors.err
theme.magenta = colors.dis
theme.transparent = "#00000000"

theme.fg = colors.fg

theme.bg = colors.bg
theme.bg_alt = colors.mbg
theme.mbg = colors.mbg
theme.bg3 = colors.bg3
theme.bg4 = colors.bg4

theme.fg = colors.fg
theme.fg1 = colors.fg2
theme.fg2 = colors.fg3
theme.fg3 = colors.fg4

-- Gradient Colors Using Cairo
-- -------------------------------------------------------------------------- --
-- general
theme.bg_gradient = "linear:0,0:180,0:1800,"
    .. helpers.color_lighten(theme.mbg, 25)
    .. "ee:0.25,"
    .. helpers.color_lighten(theme.bg, 45)
    .. "ee:0.5,"
    .. helpers.color_lighten(theme.bg3, 0)
    .. "ee:0.55,"
    .. helpers.color_lighten(theme.bg, 35)
    .. "ee:0.6,"
    .. helpers.color_lighten(theme.mbg, 10)
    .. "ee:0.75,"
    .. helpers.color_lighten(theme.mbg, 25)
    .. "ee:1,"
    .. helpers.color_lighten(theme.bg, 30)
    .. "ee"
-- -------------------------------------------------------------------------- --
theme.bg_gradient2 = "linear:180,0:23,180:0,"
    .. helpers.color_lighten(theme.mbg, 35)
    .. "ee:0.25,"
    .. helpers.color_lighten(theme.mbg, 20)
    .. "ee:0.4,"
    .. helpers.color_lighten(theme.bg, 50)
    .. "ee:0.5,"
    .. helpers.color_lighten(theme.bg3, 10)
    .. "ee:0.6,"
    .. helpers.color_lighten(theme.bg3, 5)
    .. "ee:0.75,"
    .. helpers.color_lighten(theme.bg3, 5)
    .. "ee:1,"
    .. helpers.color_lighten(theme.mbg, 15)
    .. "ee"

-- -------------------------------------------------------------------------- --
-- titlebar
theme.bg_gradient_titlebar = "linear:180,0:32,180:0,"
    .. helpers.color_lighten(theme.mbg, 15)
    .. "ee:0.25,"
    .. helpers.color_lighten(theme.mbg, 5)
    .. "ee:0.5,"
    .. helpers.color_lighten(theme.bg, 25)
    .. "ee:0.75,"
    .. helpers.color_lighten(theme.mbg, 15)
    .. "ee:1,"
    .. helpers.color_lighten(theme.mbg, 5)
    .. "ee"

-- -------------------------------------------------------------------------- --
theme.bg_gradient_titlebar2 = "linear:180,0:23,180:0,"
    .. helpers.color_darken(theme.fg3, 10)
    .. "ee:0.25,"
    .. helpers.color_lighten(theme.bg, 35)
    .. "ee:0.5,"
    .. helpers.color_lighten(theme.bg, 25)
    .. "ee:0.75,"
    .. helpers.color_lighten(theme.bg, 45)
    .. "ee:1,"
    .. helpers.color_darken(theme.bg4, 30)
    .. "ee"

-- -------------------------------------------------------------------------- --
-- tags (3D Skeuomorphic)
theme.bg_gradient_tag = "radial:0.5,0.5:0.5,0.5:0.4," -- Centered, smaller radius for 3d
    .. helpers.color_darken(theme.fg3, 25)
    .. "ee:0.25,"
    .. helpers.color_darken(theme.fg, 10)
    .. "ee:0.5,"
    .. helpers.color_lighten(theme.fg, 15)
    .. "ee:0.75,"
    .. helpers.color_darken(theme.fg3, 25)
    .. "ee:1,"
    .. helpers.color_darken(theme.bg4, 5)
    .. "ee"

-- -------------------------------------------------------------------------- --
-- tags2 (3D Skeuomorphic)
theme.bg_gradient_tag2 = "radial:0.5,0.5:0.5,0.5:0.4," -- Centered, smaller radius
    .. helpers.color_darken(theme.fg, 15)
    .. "ee:0.25,"
    .. helpers.color_lighten(theme.fg3, 15)
    .. "ee:0.5,"
    .. helpers.color_lighten(theme.fg3, 10)
    .. "ee:0.75,"
    .. helpers.color_darken(theme.fg3, 15)
    .. "ee:1,"
    .. helpers.color_darken(theme.fg3, 30)
    .. "ee"

-- -------------------------------------------------------------------------- --
-- tags3 (3D Skeuomorphic)
theme.bg_gradient_tag3 = "radial:0.5,0.5:0.5,0.5:0.4," -- Centered, smaller radius
    .. helpers.color_lighten(theme.mbg, 45)
    .. "ee:0.25,"
    .. helpers.color_darken(theme.fg3, 5)
    .. "ee:0.5,"
    .. helpers.color_lighten(theme.mbg, 35)
    .. "ee:0.75,"
    .. helpers.color_darken(theme.fg3, 5)
    .. "ee:1,"
    .. helpers.color_lighten(theme.fg2, 20)
    .. "ee"
-- -------------------------------------------------------------------------- --
-- tags4 (3D Skeuomorphic)
theme.bg_gradient_tag4 = "radial:0.5,0.5:0.5,0.5:0.4," -- Centered, smaller radius
    .. helpers.color_lighten(theme.mbg, 45)
    .. "ee:0.25,"
    .. helpers.color_darken(theme.fg3, 5)
    .. "ee:0.5,"
    .. helpers.color_lighten(theme.mbg, 35)
    .. "ee:0.75,"
    .. helpers.color_darken(theme.fg3, 5)
    .. "ee:1,"
    .. helpers.color_lighten(theme.fg2, 20)
    .. "ee"
-- -------------------------------------------------------------------------- --
-- buttons
-- buttons
theme.bg_gradient_button = "radial:0,0:272,272:1,"
    .. helpers.color_darken(theme.fg3, 40)
    .. "dd:0.25,"
    .. helpers.color_darken(theme.fg, 50)
    .. "dd:0.4,"
    .. helpers.color_darken(theme.fg, 45)
    .. "dd:0.5,"
    .. helpers.color_darken(theme.fg3, 10)
    .. "ee:0.6,"
    .. helpers.color_darken(theme.fg3, 20)
    .. "dd:0.75,"
    .. helpers.color_darken(theme.fg3, 20)
    .. "ee:1,"
    .. helpers.color_darken(theme.fg3, 40)
    .. "ee"

-- -------------------------------------------------------------------------- --
theme.bg_gradient_button2 = "linear:180,0:23,180:0,"
    .. helpers.color_darken(theme.fg3, 80)
    .. "ee:0.25,"
    .. helpers.color_lighten(theme.bg, 20)
    .. "ee:0.5,"
    .. helpers.color_lighten(theme.bg, 15)
    .. "ee:0.75,"
    .. helpers.color_lighten(theme.bg, 5)
    .. "ee:1,"
    .. helpers.color_darken(theme.bg4, 40)
    .. "ee"

-- Menu

theme.menu_height = dpi(40)
theme.menu_width = dpi(200)
theme.menu_bg_focus = theme.mbg
theme.menu_bg_normal = theme.bg
theme.submenu = ">"

theme.taglist_bg = theme.bg_gradient_tag
theme.taglist_bg_focus = theme.bg_gradient_tag2
theme.taglist_fg_focus = theme.fg .. "aa"
theme.taglist_bg_urgent = theme.red
theme.taglist_fg_urgent = theme.fg
theme.taglist_bg_occupied = theme.bg_gradient_tag3
theme.taglist_fg_occupied = theme.fg .. "55"
theme.taglist_bg_empty = theme.bg_gradient_tag4
theme.taglist_fg_empty = colors.fg
theme.taglist_font = "awesomewm-font Regular 11"
theme.taglist_spacing = dpi(2)

theme.tasklist_bg_normal = theme.bg
theme.tasklist_bg_focus = theme.bg2
theme.tasklist_bg_minimize = theme.bg3

-- titlebar

theme.titlebar_bg_normal = theme.bg_gradient_titlebar
theme.titlebar_bg_focus = theme.bg_gradient_titlebar2
theme.titlebar_fg_normal = colors.fg3
theme.titlebar_fg_focus = colors.fg

theme.icon_theme = "Reversal"
theme.nixos = themes_path .. "assets/nixos.png"

theme.songdefpicture = themes_path .. "/assets/defsong.jpg"

rnotification.connect_signal("request::rules", function()
    rnotification.append_rule({
        rule = { urgency = "critical" },
        properties = { bg = theme.red, fg = "#ffffff" },
    })
end)

-- -------------------------------------------------------------------------- --
-- Layout icons

theme.layout_fairh = gears.color.recolor_image(
    assets_path .. "/layouts/fairh.png",
    theme.fg_normal
)
theme.layout_fairv = gears.color.recolor_image(
    assets_path .. "/layouts/fairv.png",
    theme.fg_normal
)
theme.layout_floating = gears.color.recolor_image(
    assets_path .. "/layouts/floating.png",
    theme.fg_normal
)
theme.layout_magnifier = gears.color.recolor_image(
    assets_path .. "/layouts/magnifier.png",
    theme.fg_normal
)
theme.layout_max = gears.color.recolor_image(
    assets_path .. "/layouts/max.png",
    theme.fg_normal
)
theme.layout_fullscreen = gears.color.recolor_image(
    assets_path .. "/layouts/fullscreen.png",
    theme.fg_normal
)
theme.layout_tilebottom = gears.color.recolor_image(
    assets_path .. "/layouts/tilebottom.png",
    theme.fg_normal
)
theme.layout_tileleft = gears.color.recolor_image(
    assets_path .. "/layouts/tileleft.png",
    theme.fg_normal
)
theme.layout_tile = gears.color.recolor_image(
    assets_path .. "/layouts/tile.png",
    theme.fg_normal
)
theme.layout_tiletop = gears.color.recolor_image(
    assets_path .. "/layouts/tiletop.png",
    theme.fg_normal
)
theme.layout_spiral = gears.color.recolor_image(
    assets_path .. "/layouts/spiral.png",
    theme.fg_normal
)
theme.layout_dwindle = gears.color.recolor_image(
    assets_path .. "/layouts/dwindle.png",
    theme.fg_normal
)
theme.layout_cornernw = gears.color.recolor_image(
    assets_path .. "/layouts/cornernw.png",
    theme.fg_normal
)
theme.layout_cornerne = gears.color.recolor_image(
    assets_path .. "/layouts/cornerne.png",
    theme.fg_normal
)
theme.layout_cornersw = gears.color.recolor_image(
    assets_path .. "/layouts/cornersw.png",
    theme.fg_normal
)
theme.layout_cornerse = gears.color.recolor_image(
    assets_path .. "/layouts/cornerse.png",
    theme.fg_normal
)
-- -------------------------------------------------------------------------- --
-- custom layout icons

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
theme.layout_mstab = gears.color.recolor_image(
    assets_path .. "/layouts/mstab.png",
    theme.fg_normal
)

theme.layout_floating =
    gears.color.recolor_image(themes_path .. "assets/floating.png", theme.fg)
theme.layout_tile =
    gears.color.recolor_image(themes_path .. "assets/tile.png", theme.fg)

return theme
