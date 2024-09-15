local awful = require("awful")

screen.connect_signal("request::desktop_decoration", function(s)
	awful.tag({ "A", "W", "E", "S", "O", "M", "E" }, s, awful.layout.layouts[1])
end)
