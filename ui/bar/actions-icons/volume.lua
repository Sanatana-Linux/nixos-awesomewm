---@diagnostic disable: undefined-global
local wibox = require('wibox')
local beautiful = require('beautiful')
local awful = require('awful')
local dpi = beautiful.xresources.apply_dpi

local volume = wibox.widget({
	widget = wibox.widget.imagebox,
	forced_height = dpi(20),
	forced_width = dpi(20),
	image = beautiful.volume_on,
	halign = 'center',
	valign = 'bottom',
})

local tooltip = utilities.make_popup_tooltip(
	'Press to mute/unmute',
	function(d)
		return awful.placement.bottom_right(d, {
			margins = {
				bottom = beautiful.bar_height + beautiful.useless_gap * 2,
				right = beautiful.useless_gap * 2 + 75,
			},
		})
	end
)

tooltip.attach_to_object(volume)

volume:add_button(awful.button({}, 1, function() awful.spawn('amixer set Master toggle') end))

awesome.connect_signal('signal::volume', function(vol, is_muted)
	if is_muted == 1 or vol == 0 then
		volume.image = icons.muted
	else
		volume.image = icons.volume_high
	end
end)

return volume
