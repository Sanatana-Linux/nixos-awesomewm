local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local gcolor = require("gears.color")
local gfs = require("gears.filesystem")
local dpi = beautiful.xresources.apply_dpi
local shapes = require("modules.shapes")

-- Use same icons as power menu for consistency
local icons_dir = gfs.get_configuration_dir() .. "ui/popups/powermenu/icons/"

local function create_power_button(icon_path, action, color)
    local button = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg_gradient_button_alt,
        border_width = dpi(1.5),
        border_color = beautiful.fg_alt .. "99",
        forced_width = dpi(80),
        forced_height = dpi(80),
        shape = shapes.rrect(8),
        buttons = {
            awful.button({}, 1, function()
                action()
            end),
        },
        {
            widget = wibox.container.margin,
            margins = dpi(15),
            {
                widget = wibox.container.place,
                halign = "center",
                valign = "center",
                {
                    widget = wibox.widget.imagebox,
                    image = gcolor.recolor_image(icon_path, beautiful.fg), -- White icons normally
                    resize = true,
                    forced_width = dpi(36),
                    forced_height = dpi(36),
                    id = "button_icon",
                },
            },
        },
    })

    -- Hover effects - match power menu but with special red handling for poweroff
    button:connect_signal("mouse::enter", function(w)
        local icon_widget = w:get_children_by_id("button_icon")[1]
        if color == beautiful.red then
            -- Red gradient background for poweroff (like close buttons)
            w:set_bg("linear:0,0:0,32:0," .. beautiful.red .. ":1," .. "#b61442")
            if icon_widget then
                icon_widget:set_image(gcolor.recolor_image(icon_path, beautiful.fg))
            end
        else
            -- Normal hover gradient for other buttons
            local hover_gradient = "linear:0,0:0,32:0," .. color .. ":1," .. color .. "cc"
            w:set_bg(hover_gradient)
            if icon_widget then
                icon_widget:set_image(gcolor.recolor_image(icon_path, beautiful.fg))
            end
        end
    end)

    button:connect_signal("mouse::leave", function(w)
        w:set_bg(beautiful.bg_gradient_button_alt)
        local icon_widget = w:get_children_by_id("button_icon")[1]
        if icon_widget then
            icon_widget:set_image(gcolor.recolor_image(icon_path, beautiful.fg)) -- Back to white
        end
    end)

    return button
end

-- Create power buttons with same icons and actions as power menu (minus lock)
local power_buttons = wibox.widget({
    {
        create_power_button(icons_dir .. "poweroff.svg", function()
            awful.spawn("systemctl poweroff")
        end, beautiful.red),
        
        create_power_button(icons_dir .. "reboot.svg", function() 
            awful.spawn("systemctl reboot")
        end, beautiful.yellow),
        
        create_power_button(icons_dir .. "power-sleep.svg", function()
            awful.spawn("systemctl suspend")
        end, beautiful.blue),
        
        spacing = dpi(12),
        layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
    halign = "center",
    valign = "center",
})

return power_buttons