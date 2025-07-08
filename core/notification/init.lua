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
            timeout = 5       -- Set a default timeout of 5 seconds for most notifications
        }
    }

    -- Create a specific rule for screenshot notifications to make them persistent
    rnotification.append_rule {
        id = "screenshot_rule",
        rule = {
            app_name = "Screenshot" -- Match notifications from our screenshot service
        },
        properties = {
            timeout = 0 -- A timeout of 0 means the notification will not automatically close
        }
    }
end)

-- Clean up notifications when AwesomeWM exits
capi.awesome.connect_signal("exit", function()
    -- Destroy all active notifications silently when the window manager shuts down
    naughty.destroy_all_notifications(nil, ncr.silent)  -- nil = all notifications, silent = no sound/animation
end)