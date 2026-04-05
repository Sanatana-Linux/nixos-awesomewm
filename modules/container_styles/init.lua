local wibox = require("wibox")
local beautiful = require("beautiful")
local ui_constants = require("modules.ui_constants")
local shapes = require("modules.shapes")

-- Common container and layout patterns
local container_styles = {}

-- Standard background container with rounded corners
function container_styles.rounded_bg(args)
    args = args or {}
    return {
        widget = wibox.container.background,
        bg = args.bg or beautiful.bg_alt,
        fg = args.fg or beautiful.fg,
        shape = shapes.rrect(args.radius or ui_constants.RADIUS.MEDIUM),
        border_width = args.border_width or ui_constants.BORDER.THIN,
        border_color = args.border_color or beautiful.border_color_normal,
    }
end

-- Standard margin container with consistent spacing
function container_styles.padded(args)
    args = args or {}
    local margin_size = args.margin or ui_constants.SPACING.LARGE
    
    return {
        widget = wibox.container.margin,
        margins = args.margins or {
            left = args.left or margin_size,
            right = args.right or margin_size,
            top = args.top or margin_size,
            bottom = args.bottom or margin_size,
        },
    }
end

-- Combined rounded background with padding
function container_styles.rounded_padded(args)
    args = args or {}
    local bg_args = {
        bg = args.bg,
        fg = args.fg,
        radius = args.radius,
        border_width = args.border_width,
        border_color = args.border_color,
    }
    local padding_args = {
        margin = args.margin,
        margins = args.margins,
        left = args.left,
        right = args.right,
        top = args.top,
        bottom = args.bottom,
    }
    
    local bg_container = container_styles.rounded_bg(bg_args)
    local padding_container = container_styles.padded(padding_args)
    
    -- Nest padding inside background
    bg_container[1] = padding_container
    return bg_container
end

-- Separator widget
function container_styles.separator(orientation, thickness)
    orientation = orientation or "horizontal"
    thickness = thickness or beautiful.separator_thickness
    
    return {
        widget = wibox.container.background,
        forced_width = orientation == "vertical" and thickness or 1,
        forced_height = orientation == "horizontal" and thickness or 1,
        {
            widget = wibox.widget.separator,
            orientation = orientation,
        },
    }
end

-- Icon + text horizontal layout
function container_styles.icon_text_layout(icon_widget, text_widget, spacing)
    return {
        layout = wibox.layout.fixed.horizontal,
        spacing = spacing or ui_constants.SPACING.MEDIUM,
        icon_widget,
        text_widget,
    }
end

return container_styles