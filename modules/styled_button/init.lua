local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")
local dpi = beautiful.xresources.apply_dpi
local shapes = require("modules.shapes")

-- Styled button module that replicates the taglist/tasklist button appearance
-- with inner + outer containers, proper gradient backgrounds, and hover effects
local styled_button = {}

-- Creates a button with the exact styling used by taglist/tasklist buttons
-- @param args Table with the following optional fields:
--   - content: The widget content (required)
--   - width: Fixed width for the content area (default: dpi(26))
--   - height: Fixed height for the content area (default: dpi(26))
--   - margin_top: Top margin (default: dpi(2))
--   - margin_bottom: Bottom margin (default: dpi(2))
--   - margin_left: Left margin (default: dpi(12))
--   - margin_right: Right margin (default: dpi(12))
--   - buttons: Button bindings table (default: {})
--   - selected: Whether button should appear selected (default: false)
--   - on_hover: Custom hover callback function (optional)
--   - on_leave: Custom leave callback function (optional)
-- @return widget The styled button widget
function styled_button.create(args)
    args = args or {}

    local button_shape = args.shape
        or shapes.rrect(beautiful.border_radius or dpi(8))

    local content_widget
    if args.width and args.height then
        content_widget = wibox.widget({
            {
                args.content,
                widget = wibox.container.place,
                halign = "center",
                valign = "center",
            },
            width = args.width,
            height = args.height,
            widget = wibox.container.constraint,
        })
    else
        content_widget = args.content
    end

    local inner_container = wibox.widget({
        {
            content_widget,
            top = args.margin_top or dpi(2),
            bottom = args.margin_bottom or dpi(2),
            left = args.margin_left or dpi(12),
            right = args.margin_right or dpi(12),
            widget = wibox.container.margin,
        },
        shape = button_shape,
        border_width = dpi(0),
        border_color = beautiful.border_color_active,
        bg = args.selected and beautiful.bg_gradient_button_alt
            or beautiful.bg_gradient_button,
        widget = wibox.container.background,
    })

    local outer_container = wibox.widget({
        {
            inner_container,
            top = dpi(1),
            bottom = dpi(1),
            left = dpi(1),
            right = dpi(1),
            widget = wibox.container.margin,
        },
        shape = button_shape,
        border_width = dpi(1),
        border_color = args.selected and (beautiful.fg .. "66")
            or "transparent",
        bg = args.selected and beautiful.bg_gradient_button_alt
            or beautiful.bg_gradient_button,
        widget = wibox.container.background,
    })

    -- Store containers for external access
    outer_container._inner_container = inner_container
    outer_container._content_widget = content_widget

    -- Function to update button state (for selected/unselected appearance)
    function outer_container:set_selected(selected)
        if selected then
            inner_container.bg = beautiful.bg_gradient_button_alt
            inner_container.border_color = beautiful.border_color_active
                or beautiful.fg_alt
            outer_container.bg = beautiful.bg_gradient_button_alt
            outer_container.border_color = beautiful.fg .. "66"
        else
            inner_container.bg = beautiful.bg_gradient_button
            inner_container.border_color = beautiful.border_color_normal
                or beautiful.bg_urg
            outer_container.bg = beautiful.bg_gradient_button
            outer_container.border_color = "transparent"
        end
    end

    -- Function to revert to selected/unselected state (used after hover)
    local function revert_to_state()
        outer_container:set_selected(args.selected or false)
    end

    -- Hover effects (same as taglist/tasklist buttons)
    outer_container:connect_signal("mouse::enter", function()
        inner_container.bg = beautiful.bg_gradient_recessed
        outer_container.bg = beautiful.bg_gradient_recessed
        outer_container.border_color = beautiful.fg .. "66"
        if args.on_hover then
            args.on_hover()
        end
    end)

    outer_container:connect_signal("mouse::leave", function()
        revert_to_state() -- Revert to selected/unselected state
        if args.on_leave then
            args.on_leave()
        end
    end)

    -- Apply button bindings if provided
    if args.buttons and #args.buttons > 0 then
        outer_container:buttons(args.buttons)
    end

    -- Set initial state
    outer_container:set_selected(args.selected or false)

    return outer_container
end

function styled_button.create_icon_button(args)
    args = args or {}

    local sz = args.icon_size or dpi(32)
    local pad = args.padding or dpi(3)
    local icon_widget = wibox.widget({
        widget = wibox.widget.imagebox,
        image = args.icon,
        resize = true,
        forced_width = sz,
        forced_height = sz,
    })

    local btn = wibox.widget({
        {
            {
                icon_widget,
                left = pad + dpi(2),
                right = pad + dpi(1),
                top = pad,
                bottom = pad,
                widget = wibox.container.margin,
            },
            layout = wibox.layout.fixed.horizontal,
        },
        shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, dpi(6))
        end,
        border_width = dpi(1),
        border_color = beautiful.fg .. "00",
        bg = beautiful.bg_gradient_button,
        widget = wibox.container.background,
    })

    btn:connect_signal("mouse::enter", function()
        btn.bg = beautiful.bg_gradient_button_alt
        btn.border_color = beautiful.fg .. "66"
    end)

    btn:connect_signal("mouse::leave", function()
        btn.bg = beautiful.bg_gradient_button
        btn.border_color = beautiful.fg .. "00"
    end)

    if args.buttons and #args.buttons > 0 then
        btn:buttons(args.buttons)
    end

    return btn
end

-- Convenience function to create a text button with the styled button appearance
-- @param args Table with the following fields:
--   - text: Button text (required)
--   - font: Font for the text (default: beautiful.font)
--   - buttons: Button bindings table (default: {})
--   - selected: Whether button should appear selected (default: false)
--   - All other args from styled_button.create
-- @return widget The styled text button widget
function styled_button.create_text_button(args)
    args = args or {}

    local text_widget = wibox.widget({
        widget = wibox.widget.textbox,
        text = args.text,
        font = args.font or beautiful.font,
        align = "center",
        valign = "center",
    })

    -- Remove text-specific args and pass the rest to create()
    local button_args = {}
    for key, value in pairs(args) do
        if key ~= "text" and key ~= "font" then
            button_args[key] = value
        end
    end
    button_args.content = text_widget

    return styled_button.create(button_args)
end

return styled_button
