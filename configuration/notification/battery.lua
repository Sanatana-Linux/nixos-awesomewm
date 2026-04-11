-- configuration/notification/battery.lua
-- Low battery notification service that monitors battery levels and shows
-- warnings when the battery is getting low or critically low.

local naughty = require("naughty")
local battery = require("service.battery")

local lowNotified = false
local criticalNotified = false

-- Connect to battery level changes
local battery_service = battery.get_default()

battery_service:connect_signal("property::level", function(_, percent)
    print("battery is at " .. percent)
    if not battery_service.is_charging then
        if percent <= 15 and percent >= 8 and not lowNotified then
            lowNotified = true
            naughty.notify({
                category = "battery-low",
                title = "Low Battery",
                text = "Battery is at "
                    .. tostring(percent)
                    .. "%, time to find the charging cable.",
                urgency = "critical",
            })
        end

        if percent <= 8 and not criticalNotified then
            criticalNotified = true
            naughty.notify({
                category = "battery-critical",
                title = "Critical Battery",
                text = "Battery is at "
                    .. tostring(percent)
                    .. "%, you have minutes before it shuts itself off.",
                urgency = "critical",
            })
        end
    end
end)

-- Reset notification flags when charging begins
battery_service:connect_signal("property::is_charging", function(_, is_charging)
    if is_charging then
        lowNotified = false
        criticalNotified = false
    end
end)
