local awful = require('awful')
local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi
local watch = require('awful.widget.watch')
local beautiful = require('beautiful')

-- create battery widgets components
local baticon = wibox.widget.imagebox()

local batperc = wibox.widget.textbox()
batperc.font = beautiful.title_font .. ' 11'

local charging = wibox.widget({
	image = icons.bolt,
	widget = wibox.widget.imagebox,
})

local warning = wibox.widget({
	text = '',
	font = beautiful.nerd_font .. ' 14',
	widget = wibox.widget.textbox,
})

-- battery warning not visible by default
warning.visible = false

-- update icons and percentage
gears.timer({
	timeout = 5,
	call_now = true,
	autostart = true,
	callback = function()
		--  if battery widget is not visible or correctly showing replace BA* in a scripts below with (BAT1, BAT0 whatever you have.)
		awful.spawn.easy_async_with_shell('cat /sys/class/power_supply/BA*/capacity', function(stdout)
			local battery = tonumber(stdout)
			awful.spawn.easy_async_with_shell('cat /sys/class/power_supply/BA*/status', function(out)
				if string.match(out, 'Charging') then
					charging.visible = true
				else
					charging.visible = false
				end
				batperc.text = tonumber(battery) .. '%'
				if battery <= 10 then
					baticon.image = icons.battery_alert_red
					if charging.visible then
						warning.visible = false
					else
						warning.visible = true
					end
				elseif battery <= 15 then
					baticon.image = icons.battery_alert
					if charging.visible then
						warning.visible = false
					else
						warning.visible = true
					end
				elseif battery <= 20 then
					baticon.image = icons.battery_discharging_20
				elseif battery <= 30 then
					baticon.image = icons.battery_discharging_30
				elseif battery <= 40 then
					baticon.image = icons.battery_discharging_40
				elseif battery <= 50 then
					baticon.image = icons.battery_discharging_50
				elseif battery <= 60 then
					baticon.image = icons.battery_discharging_60
				elseif battery <= 70 then
					baticon.image = icons.battery_discharging_70
				elseif battery <= 80 then
					baticon.image = icons.battery_discharging_60
				elseif battery <= 90 then
					baticon.image = icons.battery_discharging_60
				elseif battery <= 100 then
					baticon.image = icons.battery_fully_charged
				end
			end)
		end)
	end,
})

-- return widget
local battery_button = utilities.mkbtn({
	{
		wibox.widget({
			baticon,
			widget = wibox.container.margin,
			margins = dpi(4),
		}),
		wibox.widget({
			batperc,
			fg = beautiful.fg_normal,
			widget = wibox.container.background,
		}),
		wibox.widget({
			charging,
			fg = beautiful.fg_normal,
			widget = wibox.container.background,
		}),
		wibox.widget({
			warning,
			fg = beautiful.red,
			widget = wibox.container.background,
		}),
		spacing = dpi(2),
		layout = wibox.layout.fixed.horizontal,
		border_color = beautiful.grey,
		border_width = dpi(1.25),
		widget = wibox.container.background,
		bg = beautiful.widget_back,
		shape = utilities.mkroundedrect(),
	},
	left = dpi(3),
	right = dpi(2),
	widget = wibox.container.margin,
}, beautiful.widget_back, beautiful.widget_back_focus)

return battery_button
