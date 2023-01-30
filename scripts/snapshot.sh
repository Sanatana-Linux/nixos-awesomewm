#!/bin/bash
#                                 __           __
# .-----.-----.---.-.-----.-----.|  |--.-----.|  |_
# |__ --|     |  _  |  _  |__ --||     |  _  ||   _|
# |_____|__|__|___._|   __|_____||__|__|_____||____|
#                   |__|
###########################################################################
###########################################################################
###########################################################################
# Takes Screenshots, diplays a notification afterwards which enables some
# options as buttons in the notification.
###########################################################################
###########################################################################
###########################################################################

screenshot_dir="$HOME"/Pictures/Screenshots/
###########################################################################
###########################################################################
###########################################################################
# Check save directory
# Create it if it doesn't exist
function check_dir() {
	if [ ! -d "$screenshot_dir" ]; then
		mkdir -p "$screenshot_dir"
	fi
}
###########################################################################
###########################################################################
###########################################################################
# Main function
function shot() {
	# Make sure directory exists
	check_dir
	###########################################################################
	###########################################################################
	###########################################################################
	# Names File
	file_loc="${screenshot_dir}$(date +%Y%m%d_%H%M%S).png"
	###########################################################################
	###########################################################################
	###########################################################################
	# Provides parameters from input
	maim_command="$1"
	notif_message="$2"
	###########################################################################
	###########################################################################
	###########################################################################
	# Execute maim command
	${maim_command} "${file_loc}"
	###########################################################################
	###########################################################################
	###########################################################################
	# Exit if the user cancels the screenshot
	# So it means there's no new screenshot image file
	if [ ! -f "${file_loc}" ]; then
		exit
	fi
	###########################################################################
	###########################################################################
	###########################################################################
	# Copy to clipboard
	xclip -selection clipboard -t image/png -i "${screenshot_dir}"/"$(ls -1 -t "${screenshot_dir}" | head -1)" &

	###########################################################################
	###########################################################################
	###########################################################################
	awesome-client "

	-- IMPORTANT NOTE: THIS PART OF THE SCRIPT IS LUA!
	-- MORE IMPORTANT NOTE: This CANNOT be ruin outside of AwesomeWM. It requires various libraries and functions from it to work.
	naughty = require('naughty')
	awful = require('awful')
	beautiful = require('beautiful')
	dpi = beautiful.xresources.apply_dpi

	local open_image = naughty.action {
		name = 'Open',
	   	icon_only = false,
	}

	local open_folder = naughty.action {
		name = 'Open Folder',
	   	icon_only = false,
	}

	local delete_image = naughty.action {
		name = 'Delete',
	   	icon_only = false,
	}

	-- Execute the callback when 'Open' is pressed
	open_image:connect_signal('invoked', function()
		awful.spawn('xdg-open ' .. '${file_loc}', false)
	end)

	open_folder:connect_signal('invoked', function()
		awful.spawn('xdg-open ' .. '${screenshot_dir}', false)
	end)

	-- Execute the callback when 'Delete' is pressed
	delete_image:connect_signal('invoked', function()
		awful.spawn('rm ' .. '${file_loc}', false)
	end)

	-- Show notification
	naughty.notification ({
		app_name = 'Screenshot Tool',
		icon = '${file_loc}',
		timeout = 0,
		title = '<b>Screenshot Taken</b>',
		message = '${notif_message}',
		actions = { open_image, open_folder, delete_image }
	})
    "

}
###########################################################################
###########################################################################
###########################################################################
# If incorrect or no parameter is passed
if [ -z "$1" ] || ([ "$1" != 'full' ] && [ "$1" != 'area' ]); then
	echo "
	Requires an argument:
	area 	- Area screenshot
	full 	- Fullscreen screenshot

	Example:
	./snapshot.sh area
	./snapshot.sh full
    "
# Assigns behavior based on parameter
elif [ "$1" = 'full' ]; then
	msg="Full screenshot saved and copied to clipboard!"
	shot 'maim -u -m 1' "${msg}"
elif [ "$1" = 'area' ]; then
	msg='Area screenshot saved and copied to clipboard!'
	shot 'maim -u -s -n -m 1' "${msg}"
fi
