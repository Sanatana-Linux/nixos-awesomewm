--[[
Generic Applet Button Module

Creates a consistent, styled button widget for control panel applets.

Accepts configuration options for:
- Icon and labels
- Actions for toggle and reveal
- Service/Adapter integration for state-based styling
--]]

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gcolor = require("gears.color")
local shapes = require("modules.shapes")
local dpi = beautiful.xresources.apply_dpi

local function new(opts)
    opts = opts or {}

    -- Styling and content options
    local icon = opts.icon
    local name = opts.name or "Applet"
    local active_text = opts.active_text or "Enabled"
    local inactive_text = opts.inactive_text or "Disabled"
    local arrow_icon = opts.arrow_icon

    -- Actions
    local on_toggle = opts.on_toggle
    local on_reveal = opts.on_reveal

    -- Service integration for automatic state styling
    local service = opts.service
    local state_property = opts.state_property
    local get_state_func = opts.get_state_func

    local forced_width = dpi(225)
    local forced_height = dpi(60)

    -- Build the widget
    local ret = wibox.widget({
        widget = wibox.container.background,
        forced_width = forced_width,
        forced_height = forced_height,
        bg = beautiful.bg_alt,
        fg = beautiful.fg,
        shape = shapes.rrect(10),
        border_width = dpi(1),
        border_color = beautiful.border_color,
        {
            layout = wibox.layout.align.horizontal,
            -- Toggle/Info Area
            {
                id = "toggle-button",
                widget = wibox.container.background,
                forced_width = dpi(180),
                {
                    widget = wibox.container.margin,
                    margins = { left = dpi(15) },
                    {
                        layout = wibox.layout.fixed.horizontal,
                        spacing = dpi(15),
                        {
                            widget = wibox.container.place,
                            valign = "center",
                            {
                                id = "toggle-icon",
                                widget = wibox.widget.imagebox,
                                image = gcolor.recolor_image(icon, beautiful.fg),
                                forced_height = dpi(24),
                                forced_width = dpi(24),
                                resize = true,
                            },
                        },
                        {
                            widget = wibox.container.place,
                            valign = "center",
                            {
                                layout = wibox.layout.fixed.vertical,
                                {
                                    widget = wibox.widget.textbox,
                                    markup = "<b>" .. name .. "</b>",
                                },
                                {
                                    id = "state-label",
                                    widget = wibox.widget.textbox,
                                    font = beautiful.font_name .. dpi(9),
                                },
                            },
                        },
                    },
                },
            },
            -- Separator
            {
                widget = wibox.container.margin,
                margins = { top = dpi(15), bottom = dpi(15) },
                {
                    id = "separator",
                    widget = wibox.widget.separator,
                    forced_width = 1,
                    orientation = "vertical",
                    color = beautiful.border_color,
                },
            },
            -- Reveal Area
            {
                id = "reveal-button",
                widget = wibox.container.background,
                forced_width = dpi(45),
                {
                    widget = wibox.container.place,
                    valign = "center",
                    halign = "center",
                    {
                        widget = wibox.widget.imagebox,
                        image = gcolor.recolor_image(arrow_icon, beautiful.fg),
                        forced_height = dpi(18),
                        forced_width = dpi(18),
                        resize = true,
                    },
                },
            },
        },
    })

    -- References
    local toggle_button = ret:get_children_by_id("toggle-button")[1]
    local reveal_button = ret:get_children_by_id("reveal-button")[1]
    local separator = ret:get_children_by_id("separator")[1]
    local state_label = ret:get_children_by_id("state-label")[1]

    -- State update logic
    local function update_ui(is_active)
        if is_active then
            ret:set_bg(beautiful.ac)
            state_label:set_markup(active_text)
            separator:set_color(beautiful.fg)
        else
            ret:set_bg(beautiful.bg_alt)
            state_label:set_markup(inactive_text)
            separator:set_color(beautiful.border_color)
        end
    end

    -- Signals/Buttons
    if on_toggle then
        toggle_button:buttons({ awful.button({}, 1, on_toggle) })
    end
    if on_reveal then
        reveal_button:buttons({ awful.button({}, 1, on_reveal) })
    end

    if service and state_property and get_state_func then
        service:connect_signal(state_property, function(_, state)
            update_ui(state)
        end)
        update_ui(get_state_func(service))
    end

    return ret
end

return setmetatable({}, { __call = function(_, ...) return new(...) end })
