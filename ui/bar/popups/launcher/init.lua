local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local helpers = require "helpers"
local gears = require "gears"
local awful = require "awful"

local searchwidget = require "ui.bar.popups.launcher.search"

local function create_power_button(imagename, on_press, color)
	local widget = utilities.pointer_on_focus(wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_focus_dark,
		shape = beautiful.theme_shape,
		{
			widget = wibox.container.margin,
			margins = dpi(5),
			{
				widget = wibox.widget.imagebox,
				image = gears.color.recolor_image(
					gears.filesystem.get_configuration_dir() .. "/assets/materialicons/" .. imagename,
					color),
				buttons = { awful.button {
					modifiers = {},
					button = 1,
					on_press = on_press
				}}
			}
		}
	})
	widget:connect_signal("mouse::enter", function ()
		widget.bg = beautiful.bg_focus
	end)
	widget:connect_signal("mouse::leave", function ()
		widget.bg = beautiful.bg_focus_dark
	end)
	return widget
end

local function create_launcher_widgets(s)
	return wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		spacing = dpi(10),
		{
			widget = wibox.container.place,
			valign = 'bottom',
			halign = 'center',
			{
				widget = wibox.container.background,
				bg = beautiful.bg_focus_dark,
				shape = beautiful.theme_shape,
				{
					widget = wibox.container.margin,
					margins = dpi(5),
					{
						widget = wibox.container.constraint,
						strategy = "max",
						width = dpi(50),
						{
							layout = wibox.layout.fixed.vertical,
							spacing = dpi(5),
							create_power_button("poweroff.svg", function ()
								awful.spawn("poweroff")
							end, beautiful.red),
							create_power_button("restart.svg", function ()
								awful.spawn("reboot")
							end, beautiful.green),
                            create_power_button("suspend.svg", function ()
                                awful.spawn("systemctl suspend")
                            end, beautiful.cyan),
							create_power_button("lock.svg", function ()
								awful.spawn("i3lock-color -c " .. string.sub(beautiful.bg_normal,2,7) .. "60 --greeter-text='enter password' -efk --time-pos='x+w-100:y+h-50'")
							end, beautiful.yellow),
							create_power_button("logout.svg", function ()
								awful.spawn("pkill awesome")
							end, beautiful.blue),
						}
					}
				}
			}
		},
		{
			widget = wibox.container.background,
			bg = beautiful.bg_focus_dark,
			shape = beautiful.theme_shape,
			{
				widget = wibox.container.margin,
				margins = dpi(5),
				searchwidget.init(s)
			}
		}
	}
end

local function init(s)
	local w, h = dpi(450), dpi(600)

	s.launcher = wibox {
		x = s.geometry.x + 2*beautiful.useless_gap,
		y = s.geometry.y + beautiful.wibar_height + 2*beautiful.useless_gap,
		ontop = true,
		width = w,
		height = h,
		screen = s,
		widget = wibox.widget {
			widget = wibox.container.margin,
			margins = dpi(10),
			create_launcher_widgets(s)
		}
	}

	function s.launcher:show()
		self.visible = true
	end
	function s.launcher:hide()
		self.visible = false
		local searchwidget_instance = s.popup_launcher_widget
		if searchwidget_instance:is_active() then
			searchwidget_instance:stop_search()
		end
	end
end

local function show(s)
	s.launcher:show()
end

local function run_applauncher(s)
	s.launcher:show()
	s.popup_launcher_widget:start_search(true)
end

local function hide(s)
	s.launcher:hide()
end

return {
	init = init,
	show = show,
	hide = hide,
	run_applauncher = run_applauncher
}
