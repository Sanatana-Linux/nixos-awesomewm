local naughty = require("naughty")

local playerctl = require("plugins.bling").signal.playerctl.lib()

playerctl:connect_signal("metadata", function(_, title, artist, album_path, album, new, player_name)
	if new then
		naughty.notify({
			title = title,
			text = artist,
			app_name = player_name,
			image = album_path,
		})
	end
end)
