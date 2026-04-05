local awful = require("awful")
local beautiful = require("beautiful")
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
    
    -- Content widget - center the provided content in a fixed-size container
    local content_container = wibox.widget({
        args.content,
        widget = wibox.container.place,
        halign = "center",
        valign = "center",
        width = args.width or dpi(26),
        height = args.height or dpi(26),
    })

    -- Inner container with main styling (gradient background, rounded corners)
    local inner_container = wibox.widget({
        {
            content_container,
            top = args.margin_top or dpi(2),
            bottom = args.margin_bottom or dpi(2),
            left = args.margin_left or dpi(12),
            right = args.margin_right or dpi(12),
            widget = wibox.container.margin,
        },
        shape = shapes.rrect(beautiful.border_radius or dpi(8)),
        border_width = dpi(0),
        border_color = beautiful.border_color_active,
        bg = args.selected and beautiful.bg_gradient_button_alt or beautiful.bg_gradient_button,
        widget = wibox.container.background,
    })

    -- Outer container for transparent border effect (provides 3D depth)
    local outer_container = wibox.widget({
        {
            inner_container,
            top = dpi(1),
            bottom = dpi(1),
            left = dpi(1),
            right = dpi(1),
            widget = wibox.container.margin,
        },
        shape = shapes.rrect(beautiful.border_radius or dpi(8)),
        border_width = dpi(1),
        border_color = args.selected and (beautiful.fg .. "66") or "transparent",
        bg = args.selected and beautiful.bg_gradient_button_alt or beautiful.bg_gradient_button,
        widget = wibox.container.background,
    })

    -- Store containers for external access
    outer_container._inner_container = inner_container
    outer_container._content_container = content_container
    
    -- Function to update button state (for selected/unselected appearance)
    function outer_container:set_selected(selected)
        if selected then
            inner_container.bg = beautiful.bg_gradient_button_alt
            inner_container.border_color = beautiful.border_color_active or beautiful.fg_alt
            outer_container.bg = beautiful.bg_gradient_button_alt
            outer_container.border_color = beautiful.fg .. "66"
        else
            inner_container.bg = beautiful.bg_gradient_button
            inner_container.border_color = beautiful.border_color_normal or beautiful.bg_urg
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

-- Convenience function to create an icon button with the styled button appearance
-- @param args Table with the following fields:
--   - icon: Path to icon file (required)
--   - icon_size: Size of the icon (default: dpi(18))
--   - buttons: Button bindings table (default: {})
--   - selected: Whether button should appear selected (default: false)
--   - All other args from styled_button.create
-- @return widget The styled icon button widget
function styled_button.create_icon_button(args)
    args = args or {}
    
    local icon_widget = wibox.widget({
        widget = wibox.widget.imagebox,
        image = args.icon,
        resize = true,
        forced_width = args.icon_size or dpi(18),
        forced_height = args.icon_size or dpi(18),
    })
    
    -- Remove icon-specific args and pass the rest to create()
    local button_args = {}
    for key, value in pairs(args) do
        if key ~= "icon" and key ~= "icon_size" then
            button_args[key] = value
        end
    end
    button_args.content = icon_widget
    
    return styled_button.create(button_args)
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