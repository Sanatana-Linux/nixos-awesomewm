-- Simple caps lock state tracking
local awful = require("awful")

-- Track caps lock state
local caps_state = false

-- Function to check caps lock state via system command
local function check_caps_state()
    awful.spawn.easy_async("bash -c 'setleds | grep -i caps'", function(stdout)
        local new_state = stdout:match("Caps Lock on") ~= nil
        if new_state ~= caps_state then
            caps_state = new_state
            awesome.emit_signal("signal::peripheral::caps::state", caps_state)
        end
    end)
end

-- Handle caps lock updates
awesome.connect_signal("signal::peripheral::caps::update", function()
    check_caps_state()
end)

-- Initial check
check_caps_state()