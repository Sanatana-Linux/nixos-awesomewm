if not RUBATO_DIR then
	RUBATO_DIR = (...):match("(.-)[^%.]+$") .. "rubato."
end
if not MANAGER then
	MANAGER = require("modules.animations.manager")
end

return {
	--depreciated
	set_def_rate = function(rate)
		MANAGER.timed.defaults.rate = rate
	end,
	set_override_dt = function(value)
		MANAGER.timed.defaults.override_dt = value
	end,

	--Modules
	timed = require("modules.animations.timed"),
	easing = require("modules.animations.easing"),
	subscribable = require("modules.animations.subscribable"),
	manager = MANAGER,
}
