--[[
Applet Page Module

Common styling and structure for control panel applet pages.
--]]

local wibox = require("wibox")
local beautiful = require("beautiful")
local shapes = require("modules.shapes.init")
local dpi = beautiful.xresources.apply_dpi

local M = {}

M.WHITE = "#FFFFFF"

function M.create_base_page(args)
    return wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg .. "bb",
        shape = shapes.rrect(20),
        border_width = dpi(1),
        border_color = M.WHITE,
        {
            widget = wibox.container.margin,
            margins = dpi(12),
            {
                layout = wibox.layout.fixed.vertical,
                spacing = dpi(8),
                -- Main Content Area
                {
                    widget = wibox.container.background,
                    forced_height = dpi(400),
                    forced_width = dpi(400),
                    {
                        id = "content-layout",
                        layout = wibox.layout.overflow.vertical,
                        scrollbar_enabled = false,
                        step = 40,
                        spacing = dpi(3),
                    },
                },
                -- Bottom Bar (Buttons)
                {
                    id = "bottom-bar",
                    widget = wibox.container.background,
                    forced_height = dpi(50),
                    bg = beautiful.bg_alt,
                    shape = shapes.rrect(10),
                    border_width = dpi(1),
                    border_color = M.WHITE,
                    {
                        layout = wibox.layout.align.horizontal,
                        {
                            layout = wibox.layout.fixed.horizontal,
                            spacing = beautiful.separator_thickness + dpi(2),
                            spacing_widget = {
                                widget = wibox.container.margin,
                                margins = { top = dpi(12), bottom = dpi(12) },
                                {
                                    widget = wibox.widget.separator,
                                    orientation = "vertical",
                                    color = M.WHITE,
                                },
                            },
                            table.unpack(args.left_buttons or {}),
                        },
                        nil,
                        table.unpack(args.right_buttons or {}),
                    },
                },
            },
        },
    })
end

function M.create_button(args)
    return {
        id = args.id,
        widget = wibox.container.background,
        shape = shapes.rrect(10),
        border_width = dpi(1),
        border_color = M.WHITE,
        bg = beautiful.bg_gradient_button,
        forced_width = args.width or dpi(40),
        forced_height = dpi(40),
        {
            widget = wibox.container.place,
            halign = "center",
            valign = "center",
            {
                widget = wibox.container.margin,
                margins = dpi(6),
                {
                    id = args.icon_id,
                    widget = wibox.widget.imagebox,
                    image = args.icon,
                    forced_height = dpi(22),
                    forced_width = dpi(22),
                    resize = true,
                },
            },
        },
    }
end

function M.setup_button_effects(button)
    if not button then return end
    button:connect_signal("mouse::enter", function(w)
        w:set_bg(beautiful.bg_gradient_button_alt)
    end)
    button:connect_signal("mouse::leave", function(w)
        w:set_bg(beautiful.bg_gradient_button)
    end)
end

return M
