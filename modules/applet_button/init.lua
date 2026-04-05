--[[
Generic Applet Button Module

Creates a consistent, styled button widget for control panel applets.
Abstracts background colors, border styles, and state-based styling for consistency.

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

local WHITE = "#FFFFFF"

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

    local BUTTON_WIDTH = dpi(225)
    local BUTTON_HEIGHT = dpi(60)
    local TOGGLE_AREA_WIDTH = dpi(180)
    local REVEAL_AREA_WIDTH = dpi(45)

    -- Build the widget
    local ret = wibox.widget({
        widget = wibox.container.background,
        forced_width = BUTTON_WIDTH,
        forced_height = BUTTON_HEIGHT,
        bg = beautiful.bg,
        fg = beautiful.fg,
        shape = shapes.rrect(10),
        border_width = dpi(1),
        border_color = beautiful.fg_alt,
        {
            layout = wibox.layout.align.horizontal,
            -- Toggle/Info Area
            {
                id = "toggle-button",
                widget = wibox.container.background,
                forced_width = TOGGLE_AREA_WIDTH,
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
                                image = gcolor.recolor_image(
                                    icon,
                                    beautiful.fg
                                ),
                                forced_height = dpi(18),
                                forced_width = dpi(18),
                                resize = true,
                            },
                        },
                        {
                            widget = wibox.container.place,
                            valign = "center",
                            {
                                layout = wibox.layout.fixed.vertical,
                                {
                                    id = "name-label",
                                    widget = wibox.widget.textbox,
                                    markup = "<span foreground='"
                                        .. beautiful.fg
                                        .. "'><b>"
                                        .. name
                                        .. "</b></span>",
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
                    color = beautiful.fg_alt,
                },
            },
            -- Reveal Area
            {
                id = "reveal-button",
                widget = wibox.container.background,
                forced_width = REVEAL_AREA_WIDTH,
                {
                    widget = wibox.container.place,
                    valign = "center",
                    halign = "center",
                    {
                        widget = wibox.container.margin,
                        margins = dpi(6),
                        {
                            id = "reveal-icon",
                            widget = wibox.widget.imagebox,
                            image = gcolor.recolor_image(
                                arrow_icon,
                                beautiful.fg
                            ),
                            forced_height = dpi(18),
                            forced_width = dpi(18),
                            resize = true,
                        },
                    },
                },
            },
        },
    })

    -- References
    local toggle_button = ret:get_children_by_id("toggle-button")[1]
    local reveal_button = ret:get_children_by_id("reveal-button")[1]
    local toggle_icon = ret:get_children_by_id("toggle-icon")[1]
    local reveal_icon = ret:get_children_by_id("reveal-icon")[1]
    local separator = ret:get_children_by_id("separator")[1]
    local state_label = ret:get_children_by_id("state-label")[1]
    local name_label = ret:get_children_by_id("name-label")[1]

    -- Private state
    ret._private = ret._private or {}
    local wp = ret._private
    wp.is_active = false

    -- State update logic
    local function update_ui(is_active)
        wp.is_active = is_active
        if is_active then
            ret:set_bg(beautiful.bg_alt)
            ret:set_fg(beautiful.fg)
            ret:set_border_color(beautiful.fg_alt)
            toggle_button:set_bg(beautiful.bg_alt)
            state_label:set_markup(
                "<span foreground='"
                    .. beautiful.fg
                    .. "'>"
                    .. active_text
                    .. "</span>"
            )
            name_label:set_markup(
                "<span foreground='"
                    .. beautiful.fg
                    .. "'><b>"
                    .. name
                    .. "</b></span>"
            )
            toggle_icon:set_image(gcolor.recolor_image(icon, beautiful.fg))
            reveal_icon:set_image(
                gcolor.recolor_image(arrow_icon, beautiful.fg)
            )
            separator:set_color(beautiful.fg_alt)
        else
            ret:set_bg(beautiful.bg_alt)
            ret:set_fg(beautiful.fg)
            ret:set_border_color(beautiful.fg_alt)
            toggle_button:set_bg(nil)
            state_label:set_markup(
                "<span foreground='"
                    .. beautiful.fg
                    .. "'>"
                    .. inactive_text
                    .. "</span>"
            )
            name_label:set_markup(
                "<span foreground='"
                    .. beautiful.fg
                    .. "'><b>"
                    .. name
                    .. "</b></span>"
            )
            toggle_icon:set_image(gcolor.recolor_image(icon, beautiful.fg))
            reveal_icon:set_image(
                gcolor.recolor_image(arrow_icon, beautiful.fg)
            )
            separator:set_color(beautiful.fg_alt)
        end
    end

    -- Hover/Pressed logic
    local function on_hovered(is_hovered)
        if wp.is_active then
            return
        end
        if is_hovered then
            toggle_button:set_bg(beautiful.bg_urg)
            separator:set_color(beautiful.fg_alt)
        else
            toggle_button:set_bg(nil)
            separator:set_color(beautiful.fg_alt)
        end
    end

    local function on_pressed(is_pressed)
        if wp.is_active then
            return
        end
        if is_pressed then
            toggle_button:set_bg(nil)
            separator:set_color(beautiful.fg_alt)
        else
            toggle_button:set_bg(beautiful.bg_alt)
            separator:set_color(beautiful.fg_alt)
        end
    end

    -- Signals/Buttons
    toggle_button:connect_signal("mouse::enter", function()
        on_hovered(true)
    end)
    toggle_button:connect_signal("mouse::leave", function()
        on_hovered(false)
    end)
    toggle_button:connect_signal("button::press", function()
        on_pressed(true)
    end)
    toggle_button:connect_signal("button::release", function()
        on_pressed(false)
    end)

    if on_toggle then
        toggle_button:buttons({ awful.button({}, 1, on_toggle) })
    end

    reveal_button:connect_signal("mouse::enter", function()
        if not wp.is_active then
            reveal_button:set_bg(beautiful.bg_urg)
            reveal_icon:set_image(
                gcolor.recolor_image(arrow_icon, beautiful.fg)
            )
        end
    end)
    reveal_button:connect_signal("mouse::leave", function()
        if not wp.is_active then
            reveal_button:set_bg(nil)
        end
    end)

    if on_reveal then
        reveal_button:buttons({ awful.button({}, 1, on_reveal) })
    end

    if service and state_property and get_state_func then
        service:connect_signal(state_property, function()
            update_ui(get_state_func(service))
        end)
        update_ui(get_state_func(service))
    end

    -- Expose update_ui for manual override or complex logic
    ret.update_ui = update_ui

    return ret
end

return setmetatable({}, {
    __call = function(_, ...)
        return new(...)
    end,
})
