--[[
Applet Page Module

Common styling and structure for control panel applet pages.
--]]

local wibox = require("wibox")
local beautiful = require("beautiful")
local gcolor = require("gears.color")
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

function M.create_action_button(args)
    return {
        id = args.id,
        widget = wibox.container.background,
        shape = shapes.rrect(10),
        border_width = dpi(1),
        border_color = M.WHITE,
        bg = beautiful.bg_gradient_button,
        {
            widget = wibox.container.margin,
            margins = dpi(10),
            {
                id = args.label_id or "label",
                widget = wibox.widget.textbox,
                align = "center",
                markup = string.format(
                    "<span foreground='%s'>%s</span>",
                    M.WHITE,
                    args.text or ""
                ),
            },
        },
    }
end

function M.create_item_widget(args)
    return {
        id = args.id,
        widget = wibox.container.background,
        shape = shapes.rrect(10),
        border_width = dpi(1),
        border_color = M.WHITE,
        forced_height = args.height or dpi(50),
        {
            widget = wibox.container.margin,
            margins = dpi(15),
            {
                layout = wibox.layout.align.horizontal,
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(8),
                    {
                        id = "check-icon",
                        widget = wibox.widget.imagebox,
                        image = args.check_icon,
                        forced_height = dpi(14),
                        forced_width = dpi(14),
                        resize = true,
                        visible = args.is_active or false,
                    },
                    {
                        widget = wibox.container.place,
                        valign = "center",
                        {
                            widget = wibox.container.constraint,
                            width = args.name_width or dpi(250),
                            {
                                id = "name",
                                widget = wibox.widget.textbox,
                                markup = string.format(
                                    "<span foreground='%s'>%s</span>",
                                    M.WHITE,
                                    args.name or "Unknown"
                                ),
                            },
                        },
                    },
                },
                nil,
                {
                    id = "status",
                    widget = wibox.widget.textbox,
                    markup = args.status_markup or "",
                },
            },
        },
    }
end

function M.create_empty_state(args)
    local content
    if args.icon then
        content = {
            widget = wibox.widget.imagebox,
            image = gcolor.recolor_image(args.icon, M.WHITE),
            forced_height = dpi(25),
            forced_width = dpi(25),
            resize = true,
        }
    else
        content = {
            widget = wibox.widget.textbox,
            align = "center",
            font = beautiful.font_name .. dpi(12),
            markup = string.format(
                "<span foreground='%s'>%s</span>",
                M.WHITE,
                args.text or ""
            ),
        }
    end

    return wibox.widget({
        widget = wibox.container.place,
        forced_height = dpi(400),
        halign = "center",
        valign = "center",
        content,
    })
end

function M.setup_button_effects(button)
    if not button then
        return
    end
    button:connect_signal("mouse::enter", function(w)
        w:set_bg(beautiful.bg_gradient_button_alt)
    end)
    button:connect_signal("mouse::leave", function(w)
        w:set_bg(beautiful.bg_gradient_button)
    end)
end

function M.setup_item_effects(item)
    if not item then
        return
    end
    item:connect_signal("mouse::enter", function(w)
        w:set_bg(beautiful.bg_urg)
    end)
    item:connect_signal("mouse::leave", function(w)
        w:set_bg(nil)
    end)
end

return M
