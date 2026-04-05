local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi

-- Create time display widget
local time_widget = wibox.widget({
    widget = wibox.widget.textbox,
    align = "center",
    valign = "center",
    font = beautiful.font_name .. " Bold " .. dpi(42),
    markup = os.date("%H:%M"),
})

-- Create date display widget in MM-DD-YYYY format
local date_widget = wibox.widget({
    widget = wibox.widget.textbox,
    align = "center",
    valign = "center", 
    font = beautiful.font_name .. " " .. dpi(16),
    markup = os.date("%m-%d-%Y"),
})

-- Combined wordclock widget
local wordclock = wibox.widget({
    {
        time_widget,
        date_widget,
        spacing = dpi(8),
        layout = wibox.layout.fixed.vertical
    },
    widget = wibox.container.place,
    halign = "center",
    valign = "center"
})

-- Timer to update both time and date
local timer = gears.timer({
    timeout = 1,
    call_now = true,
    autostart = true,
    callback = function()
        local time_str = os.date("%H:%M")
        local date_str = os.date("%m-%d-%Y")
        
        time_widget:set_markup("<span color='" .. (beautiful.fg or "#ffffff") .. "'>" .. time_str .. "</span>")
        date_widget:set_markup("<span color='" .. (beautiful.fg_alt or "#aaaaaa") .. "'>" .. date_str .. "</span>")
    end
})

-- Function for compatibility with existing lockscreen code that changes color by time
wordclock.update_clock = function(hour, min, color)
    local time_str = string.format("%02d:%02d", hour, min)
    local date_str = os.date("%m-%d-%Y")
    
    time_widget:set_markup("<span color='" .. (color or beautiful.fg or "#ffffff") .. "'>" .. time_str .. "</span>")
    date_widget:set_markup("<span color='" .. (beautiful.fg_alt or "#aaaaaa") .. "'>" .. date_str .. "</span>")
end

return wordclock