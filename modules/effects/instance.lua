if not EFFECTS_DIR then
    EFFECTS_DIR = (...):match("(.-)[^%.]+$") .. "modules.effects."
end
if not MANAGER then
    MANAGER = require("modules.effects.manager")
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
    timed = require("modules.effects.timed"),
    easing = require("modules.effects.easing"),
    subscribable = require("modules.effects.subscribable"),
    manager = MANAGER,
}
