local naughty = require("naughty") -- Import the 'naughty' notification library

-- Connect to the 'request::display_error' signal to handle error notifications
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notify {
        app_name = "Awesome", -- Set the application name in the notification
        urgency = "critical", -- Mark the notification as critical
        -- Set the notification title, indicating if the error happened during startup
        title = "An error happened" .. (startup and " during startup!" or "!"),
        text = message -- Display the error message
    }
end)
