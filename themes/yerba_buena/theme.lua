local beautiful = require("beautiful")
local gfs = require("gears.filesystem")
local gshape = require("gears.shape")
local gcolor = require("gears.color")
local dpi = beautiful.xresources.apply_dpi

local theme_name = "yerba_buena"
local theme_path = gfs.get_configuration_dir() .. "/themes/" .. theme_name .. "/"
local icons_path = theme_path .. "icons/"

local theme = {}

theme.font_name = "Agave Nerd Font Propo Bold "
theme.font_h0 = theme.font_name .. " " .. tostring(dpi(9))
theme.font_h1 = theme.font_name .. " " .. tostring(dpi(13))
theme.font_h2 = theme.font_name .. " " .. tostring(dpi(19))
theme.font_h3 = theme.font_name .. " " .. tostring(dpi(26))
theme.font = theme.font_h1

theme.text_icons = {
-- control + shift + u in the terminal ;]
arrow_down = "",
arrow_left = "«",
arrow_right = "»",
arrow_up = "",
bell_off = "􀋞",
bell_on = "􀋚",
bluetooth = "",
calendar = "",
check = "",
check_off = "",
check_on = "",
cloud = "󰬅",
cross = "",
dash = "",
droplet = "",
exit = "",
eye_off = "",
eye_on = "",
gear = "",
home = "󰠦",
image = "🖻",
lock_off = "",
lock_on = "",
menu = "",
mic_off = "",
mic_on = "",
mist = "",
moon = "",
no_cloud = "",
poweroff = "",
rain = "",
reboot = "",
search = "",
shower_rain = "",
shrink = "",
sliders = "",
snow = "",
stretch = "",
sun = "",
switch_off = "",
switch_on = "",
thermometer = "",
thunder = "",
trash = "􀈒",
vol_off = "",
vol_on = "",
wait = "",
wifi = "",
wind = "",
}

-- Colors
theme.red = "#ED5D86"
theme.green = "#54a48d"
theme.yellow = "#FFE089"
theme.blue = "#0f88ff"
theme.magenta = "#4b287d"
theme.cyan = "#01fbff"
theme.orange = "#df8559"

theme.bg = "#1f1f22"
theme.bg_alt = "#2a2a2f"
theme.bg_urg = "#30303c"

theme.fg_alt = "#8c8c98"
theme.fg = "#f7f1ff"

theme.ac = "#9da1b8"
theme.rounded = true

theme.border_width = dpi(1)
theme.border_radius = dpi(6)
theme.separator_thickness = dpi(1)
theme.useless_gap = dpi(5)

theme.separator_color = theme.bg_urg
theme.bg_normal = theme.bg
theme.fg_normal = theme.fg


-- Gradient definitions
theme.bg_gradient = "radial:0,21:0,56:0," .. "#2a2a2acc" .. ":1," .. "#111111cc"
theme.bg_gradient_alt = "radial:0,510:0,16:0," .. "#202020cc" .. ":1," .. "#0c0c0ccc"
theme.bg_gradient_titlebar = "radial:0,510:0,16:0," .. "#202020ee" .. ":1," .. "#0c0c0cee"
theme.bg_gradient_titlebar_alt = "linear:0,0:0,21:0," .. "#262626ee" .. ":1," .. "#111111ee"
theme.bg_gradient_button = "linear:0,0:0,32:0," .. "#525252cc" .. ":1," .. "#292929cc"
theme.bg_gradient_button_alt = "linear:0,0:0,21:0," .. "#292929cc" .. ":1," .. "#3b3b3bcc"
theme.bg_gradient_panel = "linear:0,0:0,21:0," .. "#323232ee" .. ":1," .. "#222222dd"
theme.bg_gradient_recessed = "radial:0,56:0,21:0," .. "#292929cc" .. ":1," .. "#111111cc"



theme.border_color_normal = theme.bg_urg
theme.border_color_active = theme.fg_alt

theme.titlebar_bg_normal = theme.bg_gradient_titlebar
theme.titlebar_bg_focus = theme.bg_gradient_titlebar_alt
theme.titlebar_bg_urgent = theme.bg_gradient_titlebar_alt
theme.titlebar_fg_normal = theme.fg_alt
theme.titlebar_fg_focus = theme.fg
theme.titlebar_fg_urgent = theme.red

theme.notification_margins = dpi(30)
theme.notification_spacing = dpi(10)
theme.notification_timeout = 5

theme.menu_submenu = theme.text_icons.arrow_right .. " "
theme.menu_bg_normal = theme.bg
theme.menu_fg_normal = theme.fg
theme.menu_bg_focus = theme.ac
theme.menu_fg_focus = theme.bg
theme.menu_border_width = theme.border_width
theme.menu_border_color = theme.border_color



theme.systray_icon_spacing = dpi(6)
theme.bg_systray = theme.bg_gradient_panel
theme.systray_icon_size = dpi(16)

function theme.rrect(rad)
	return theme.rounded and function(cr, w, h)
		gshape.rounded_rect(cr, w, h, rad)
	end
end

function theme.rbar()
	return theme.rounded and function(cr, w, h)
		gshape.rounded_bar(cr, w, h)
	end
end

function theme.prrect(tl, tr, br, bl, rad)
	return theme.rounded and function(cr, w, h)
		gshape.partially_rounded_rect(cr, w, h, tl, tr, br, bl, rad)
	end
end

function theme.crcl(rad)
	return theme.rounded and function(cr, w, h)
		gshape.circle(cr, w, h, rad)
	end
end

theme.layout_fairh = gcolor.recolor_image(icons_path .. "/layouts/fairh.png", theme.fg)
theme.layout_fairv = gcolor.recolor_image(icons_path .. "/layouts/fairv.png", theme.fg)
theme.layout_magnifier = gcolor.recolor_image(icons_path .. "/layouts/magnifier.png", theme.fg)
theme.layout_max = gcolor.recolor_image(icons_path .. "/layouts/max.png", theme.fg)
theme.layout_fullscreen = gcolor.recolor_image(icons_path .. "/layouts/fullscreen.png", theme.fg)
theme.layout_tilebottom = gcolor.recolor_image(icons_path .. "/layouts/tilebottom.png", theme.fg)
theme.layout_tileleft = gcolor.recolor_image(icons_path .. "/layouts/tileleft.png", theme.fg)
theme.layout_tile = gcolor.recolor_image(icons_path .. "/layouts/tile.png", theme.fg)
theme.layout_tiletop = gcolor.recolor_image(icons_path .. "/layouts/tiletop.png", theme.fg)
theme.layout_spiral = gcolor.recolor_image(icons_path .. "/layouts/spiral.png", theme.fg)
theme.layout_dwindle = gcolor.recolor_image(icons_path .. "/layouts/dwindle.png", theme.fg)
theme.layout_cornernw = gcolor.recolor_image(icons_path .. "/layouts/cornernw.png", theme.fg)
theme.layout_cornerne = gcolor.recolor_image(icons_path .. "/layouts/cornerne.png", theme.fg)
theme.layout_cornersw = gcolor.recolor_image(icons_path .. "/layouts/cornersw.png", theme.fg)
theme.layout_cornerse = gcolor.recolor_image(icons_path .. "/layouts/cornerse.png", theme.fg)
theme.layout_center = gcolor.recolor_image(icons_path .. "/layouts/centermaster.png", theme.fg)
theme.layout_stackLeft = gcolor.recolor_image(icons_path .. "/layouts/stack_left.png", theme.fg)
theme.layout_stack = gcolor.recolor_image(icons_path .. "/layouts/stack.png", theme.fg)
theme.layout_cascade = gcolor.recolor_image(icons_path .. "/layouts/cascade.png", theme.fg)
theme.layout_cascadetile = gcolor.recolor_image(icons_path .. "/layouts/cascadetile.png", theme.fg)
theme.layout_floating = gcolor.recolor_image(icons_path .. "/layouts/floating.png", theme.fg)
theme.layout_thrizen = gcolor.recolor_image(icons_path .. "/layouts/thrizen.png", theme.fg)
theme.layout_horizon = gcolor.recolor_image(icons_path .. "/layouts/horizon.png", theme.fg)
theme.layout_equalarea = gcolor.recolor_image(icons_path .. "/layouts/equalarea.png", theme.fg)
theme.layout_deck = gcolor.recolor_image(icons_path .. "/layouts/deck.png", theme.fg)
theme.layout_overflow = gcolor.recolor_image(icons_path .. "/layouts/deck.png", theme.fg)
theme.layout_mstab = gcolor.recolor_image(icons_path .. "/layouts/mstab.png", theme.fg)
theme.layout_tile = gcolor.recolor_image(icons_path .. "layouts/tile.png", theme.fg)

return theme
