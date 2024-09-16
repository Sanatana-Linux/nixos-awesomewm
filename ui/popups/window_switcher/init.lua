-- Import necessary modules
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local helpers = require("helpers")

-- Import the elements module for the window switcher
local elems = require("ui.popups.window_switcher.elements")

-- Define the main function that creates the window switcher
local window_switcher = function(s)
    -- Create a widget for the window list with a specific margin
    local winlist = wibox.widget({
        widget = wibox.container.margin,
        margins = dpi(14),
        elems(),
    })

    -- Create a popup container for the window list
    local container = awful.popup({
        widget = wibox.container.background,
        ontop = true,
        visible = false,
        stretch = false,
        screen = s,
        shape = helpers.rrect(),
        placement = awful.placement.centered,
        bg = beautiful.bg3 .. "66",
        border_width = dpi(1),
        border_color = beautiful.fg3 .. "33",
    })

    -- Set up the container with the window list and a vertical layout
    container:setup({
        winlist,
        layout = wibox.layout.fixed.vertical,
    })

    -- Connect a signal to toggle the visibility of the container when the user wants to switch windows
    awesome.connect_signal("window_switcher::toggle", function()
        container.visible = not container.visible
    end)
end

-- Call the window switcher function for each screen
awful.screen.connect_for_each_screen(function(s)
    window_switcher(s)
end)
