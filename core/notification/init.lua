-- Import notification system libraries
local naughty = require("naughty")                    -- AwesomeWM's notification system
local rnotification = require("ruled.notification")   -- Rule-based notification management
local ncr = naughty.notification_closed_reason        -- Enum for notification close reasons
local capi = { awesome = awesome }                    -- Capture global awesome API

-- Set up global notification rules
rnotification.connect_signal("request::rules", function()
    -- Create a global rule that applies to all notifications
    rnotification.append_rule {
        id = "global",        -- Unique identifier for this rule
        rule = {},            -- Empty rule matches all notifications
        properties = {
            timeout = 0       -- Set timeout to 0 (notifications persist until manually dismissed)
        }
    }
end)

-- Clean up notifications when AwesomeWM exits
capi.awesome.connect_signal("exit", function()
    -- Destroy all active notifications silently when the window manager shuts down
    naughty.destroy_all_notifications(nil, ncr.silent)  -- nil = all notifications, silent = no sound/animation
end)
