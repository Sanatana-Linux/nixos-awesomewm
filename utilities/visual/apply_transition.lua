local beautiful = require("beautiful")

local color = require("plugins.color")
local rubato = require("plugins.rubato")

return function(opts)
	opts = opts or {}

	local bg = opts.bg or beautiful.widget_back
	local hbg = opts.hbg or beautiful.widget_back_focus

	local element, prop = opts.element, opts.prop

	local background = color.color({ hex = bg })
	local hover_background = color.color({ hex = hbg })

	local transition = color.transition(background, hover_background, color.transition.RGB)

	local fading = rubato.timed({ duration = 0.90 })

	fading:subscribe(function(pos)
		element[prop] = transition(pos / 100).hex
	end)

	return {
		on = function()
			fading.target = 100
		end,
		off = function()
			fading.target = 0
		end,
	}
end
