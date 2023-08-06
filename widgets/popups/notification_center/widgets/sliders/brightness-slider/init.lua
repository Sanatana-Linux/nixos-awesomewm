--  ______        __         __     __
-- |   __ \.----.|__|.-----.|  |--.|  |_.-----.-----.-----.-----.
-- |   __ <|   _||  ||  _  ||     ||   _|     |  -__|__ --|__ --|
-- |______/|__|  |__||___  ||__|__||____|__|__|_____|_____|_____|
--                   |_____|
--  _______ __ __     __
-- |     __|  |__|.--|  |.-----.----.
-- |__     |  |  ||  _  ||  -__|   _|
-- |_______|__|__||_____||_____|__|
-- ------------------------------------------------- --

local widget_name = wibox.widget({
    text = "Brightness",
    font = beautiful.font .. " 26",
    align = "left",
    widget = wibox.widget.textbox,
})
-- ------------------------------------------------- --
local widget_icon = wibox.widget({
    layout = wibox.layout.align.vertical,
    expand = "none",
    nil,
    {
        id = "icon",
        image = icons.brightness,
        resize = true,
        widget = wibox.widget.imagebox,
    },
    nil,
})
-- ------------------------------------------------- --

local widget_content = wibox.widget({
    {
        widget_icon,
        margins = dpi(6),
        widget = wibox.container.margin,
    },
    shape = utilities.widgets.mkroundedrect(),
    bg = beautiful.bg_contrast .. "66",
    widget = wibox.container.background,
})
-- ------------------------------------------------- --
local slider = wibox.widget({
    nil,
    {
        id = "brightness_slider",
        bar_shape = gears.shape.rounded_bar,
        bar_height = dpi(18),
        bar_color = beautiful.bg_normal .. "cc",
        bar_active_color = beautiful.grey .. "dd",
        handle_color = beautiful.fg_normal,
        handle_shape = utilities.widgets.mkroundedrect(),
        handle_width = dpi(24),
        handle_border_color = beautiful.bg_normal,
        handle_border_width = dpi(2),
        handle_margins = {
            left = 0,
            right = 0,
            top = dpi(3),
            bottom = dpi(3),
        },
        maximum = 100,
        value = 100,
        widget = wibox.widget.slider,
    },
    nil,
    expand = "none",
    forced_height = dpi(22),
    layout = wibox.layout.align.vertical,
})

local brightness_slider = slider.brightness_slider

local bright_time = gears.timer({
    timeout = 0.5,
    callback = function()
        local brightness_level = brightness_slider:get_value()
        if brightness_level ~= nil then
            awful.spawn("light -S " .. brightness_level, false)
            awesome.emit_signal(
                "signal::brightness",
                tonumber(brightness_level)
            )
        end
    end,
})
-- ------------------------------------------------- --
brightness_slider:connect_signal("property::value", function()
    bright_time:start()
end)
-- ------------------------------------------------- --
widget_icon:buttons(gears.table.join(
    awful.button({}, 1, nil, function()
        if brightness_slider:get_value() > 100 then
            brightness_slider:set_value(100)
            return
        end
        if brightness_slider:get_value() < 100 then
            local value = brightness_slider:get_value()
            brightness_slider:set_value(value + 5)
            local updated_value = brightness_slider:get_value()
            awesome.emit_signal("signal::brightness", updated_value)
        end
    end),
    awful.button({}, 3, nil, function()
        if brightness_slider:get_value() < 0 then
            brightness_slider:set_value(0)
            return
        end
        if brightness_slider:get_value() > 0 then
            local value = brightness_slider:get_value()
            brightness_slider:set_value(value - 5)
            local updated_value = brightness_slider:get_value()
            awesome.emit_signal("signal::brightness", updated_value)
        end
    end)
))

brightness_slider:buttons(gears.table.join(
    awful.button({}, 9, nil, function()
        if brightness_slider:get_value() > 100 then
            brightness_slider:set_value(100)
            return
        end
        brightness_slider:set_value(brightness_slider:get_value() + 5)
        local updated_value = brightness_slider:get_value()
        awesome.emit_signal("signal::brightness", updated_value)
    end),
    awful.button({}, 8, nil, function()
        if brightness_slider:get_value() < 0 then
            brightness_slider:set_value(0)
            return
        end
        brightness_slider:set_value(brightness_slider:get_value() - 5)
        local updated_value = brightness_slider:get_value()
        awesome.emit_signal("signal::brightness", updated_value)
    end)
))
-- ------------------------------------------------- --
local brightness_tooltip = awful.tooltip({
    objects = { widget_icon },
    text = "None",
    mode = "outside",
    align = "right",
    margin_leftright = dpi(2),
    margin_topbottom = dpi(2),
    preferred_positions = { "right", "left", "top", "bottom" },
})
-- ------------------------------------------------- --
local update_slider = function(percentage)
    if percentage ~= nil then
        local brightness = percentage
        brightness_slider:set_value(tonumber(brightness))
        brightness_tooltip:set_text(
            "Brightness Level is Currently: " .. brightness .. "%"
        )
    end
end

-- Update on startup
update_slider()
-- ------------------------------------------------- --
-- The emit will come from the global keybind
awesome.connect_signal("signal::brightness", function(percentage)
    update_slider(percentage)
end)
-- ---------------------------------  bg = beautiful.bg_contrast .. "66",---------------- --
local cc_brightness = wibox.widget({
    {
        {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(5),
            {
                layout = wibox.layout.align.vertical,
                expand = "none",
                nil,
                {
                    layout = wibox.layout.fixed.horizontal,
                    forced_height = dpi(64),
                    forced_width = dpi(64),
                    widget_content,
                },
                nil,
            },
            slider,
        },
        margins = dpi(5),
        widget = wibox.container.margin,
    },
    shape = utilities.widgets.mkroundedrect(),
    bg = beautiful.bg_contrast .. "66",
    fg = beautiful.fg_normal,
    widget = wibox.container.background,
})

return cc_brightness
