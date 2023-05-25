--  ______         __   __
-- |   __ \.---.-.|  |_|  |_.-----.----.--.--.
-- |   __ <|  _  ||   _|   _|  -__|   _|  |  |
-- |______/|___._||____|____|_____|__| |___  |
--                                     |_____|
--  _______         __   __   ___ __              __   __
-- |    |  |.-----.|  |_|__|.'  _|__|.----.---.-.|  |_|__|.-----.-----.-----.
-- |       ||  _  ||   _|  ||   _|  ||  __|  _  ||   _|  ||  _  |     |__ --|
-- |__|____||_____||____|__||__| |__||____|___._||____|__||_____|__|__|_____|
-- ------------------------------------------------- --
--
local gfs = require('gears.filesystem')
local naughty = require('naughty')
require('signal.battery')

local display_high = true
local display_low = true
local display_charge = true

awesome.connect_signal('signal::battery', function(percentage, state)
	local value = percentage
	-- ------------------------------------------------- --
	-- only display message if its not charging and low
	if value < 16 and display_low and state == 2 then
		naughty.notification({
			title = 'Battery Low',
			text = 'Running low at ' .. value .. '%',
			image = gfs.get_configuration_dir() .. 'themes/icons/svg/battery-alert-red.svg',
		})
		display_low = false
	end
	-- ------------------------------------------------- --
	-- only display message once if its fully charged and high
	if display_high and state == 4 and value > 90 then
		naughty.notification({
			title = 'Battery Status',
			text = 'Fully charged!',
			image = gfs.get_configuration_dir() .. 'themes/icons/svg/battery-fully-charged.svg',
		})
		display_high = false
	end

	-- only display once if charging
	if display_charge and state == 1 then
		naughty.notification({
			title = 'Battery Status',
			text = 'Charging',
			image = gfs.get_configuration_dir() .. 'icons/svg/battery-fully-charged.svg',
		})
		display_charge = false
	end

	if value < 88 and value > 18 then
		display_low = true
		display_high = true
	end

	if state == 2 then display_charge = true end
end)
