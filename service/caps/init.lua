--- Caps-lock state tracking.
-- Polls the kernel LED state via `setleds` and emits
-- `signal::peripheral::caps::state` on the global `awesome` signal bus
-- whenever the state changes. The first call kicks off the polling loop;
-- callers trigger refreshes by emitting `signal::peripheral::caps::update`.
-- @module service.caps

local awful = require("awful")

-- Current known caps-lock state (false = off, true = on)
local caps_state = false

--- Read the kernel's caps-lock LED state and emit a signal on change.
-- Async via `easy_async` on `setleds` (no `bash -c` wrapper). The result
-- is parsed with a single `match("Caps Lock on")` call. No-op emission
-- when the state hasn't changed.
local function check_caps_state()
    awful.spawn.easy_async("setleds", function(stdout)
        local new_state = stdout:match("Caps Lock on") ~= nil
        if new_state ~= caps_state then
            caps_state = new_state
            awesome.emit_signal("signal::peripheral::caps::state", caps_state)
        end
    end)
end

-- External update hook — emit `signal::peripheral::caps::update` on awesome
-- to trigger a re-read.
awesome.connect_signal("signal::peripheral::caps::update", function()
    check_caps_state()
end)

-- Initial read at module load
check_caps_state()
