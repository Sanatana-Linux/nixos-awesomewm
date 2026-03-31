--[[
Applet Button Module

Common styling and structure for control panel applet buttons.
--]]

local wibox = require("wibox")
local beautiful = require("beautiful")
local shapes = require("modules.shapes.init")
local dpi = beautiful.xresources.apply_dpi

local M = {}

M.BUTTON_WIDTH = dpi(225)
M.BUTTON_HEIGHT = dpi(60)
M.TOGGLE_AREA_WIDTH = dpi(180)
M.REVEAL_AREA_WIDTH = dpi(45)
M.WHITE = "#FFFFFF"

function M.create_base_button(args)
    return wibox.widget({
        widget = wibox.container.background,
        forced_width = M.BUTTON_WIDTH,
        forced_height = M.BUTTON_HEIGHT,
        bg = args.bg,
        fg = M.WHITE,
        shape = shapes.rrect(10),
        border_width = dpi(1),
        border_color = M.WHITE,
        {
            layout = wibox.layout.align.horizontal,
            args.toggle_area,
            {
                widget = wibox.container.margin,
                margins = { top = dpi(15), bottom = dpi(15) },
                {
                    id = "separator",
                    widget = wibox.widget.separator,
                    forced_width = 1,
                    orientation = "vertical",
                    color = M.WHITE,
                },
            },
            args.reveal_area,
        },
    })
end

return M
