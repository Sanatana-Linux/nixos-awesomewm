local wibox = require("wibox")

-- Weather functionality removed - return empty widget
return wibox.widget({
    widget = wibox.widget.textbox,
    text = "",
    visible = false,
})
