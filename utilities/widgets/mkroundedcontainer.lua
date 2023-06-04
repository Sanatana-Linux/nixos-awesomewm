local mkroundedrect = require("utilities.widgets.mkroundedrect")
local wibox = require("wibox")

-- make a rounded container for antialiasing purposes
return function(template, bg)
	return wibox.widget({
		template,
		shape = mkroundedrect(),
		bg = bg,
		widget = wibox.container.background,
	})
end
