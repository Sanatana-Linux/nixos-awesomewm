--  __  __               __     __           __ __
-- |  |/  |.-----.--.--.|  |--.|__|.-----.--|  |__|.-----.-----.-----.
-- |     < |  -__|  |  ||  _  ||  ||     |  _  |  ||     |  _  |__ --|
-- |__|\__||_____|___  ||_____||__||__|__|_____|__||__|__|___  |_____|
--               |_____|                                 |_____|
-- -------------------------------------------------------------------------- --
--
local awful = require('awful')
local menubar = require('menubar')
local hotkeys_popup = require('awful.hotkeys_popup')
-- numpad key codes 1-9
--
local numpad_map = { 87, 88, 89, 83, 84, 85, 79, 80, 81 }
-- -------------------------------------------------------------------------- --
--                                  Essential                                 --
-- -------------------------------------------------------------------------- --
--
local function set_keybindings()
	-- each of the groups listed on the hotkeys popup has been separated into
	-- its own file for readability purposes
	--
	require('configuration.keybindings.awesome')
	require('configuration.keybindings.focus')
	require('configuration.keybindings.layout')
	require('configuration.keybindings.tags')
	require('configuration.keybindings.client')
end

set_keybindings()
