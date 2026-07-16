---@diagnostic disable: undefined-global
--- Container style presets.
-- Pre-configured wibox container declarations (backgrounds, margins,
-- separators, icon+text rows). Returned as plain table widgets that
-- can be dropped into a wibox hierarchy.
-- @module modules.container_styles

local wibox = require("wibox")
local beautiful = require("beautiful")
local ui_constants = require("modules.style.ui_constants")
local shapes = require("modules.style.shapes")

-- Common container and layout patterns
local container_styles = {}

--- Rounded background container with border.
-- @tparam[opt] table args Configuration:
--   * `bg` (string): background color (default `beautiful.bg_alt`)
--   * `fg` (string): foreground color (default `beautiful.fg`)
--   * `radius` (number): corner radius (default `RADIUS.MEDIUM`)
--   * `border_width` (number): border width (default `BORDER.THIN`)
--   * `border_color` (string): border color (default `beautiful.border_color_normal`)
-- @treturn table A wibox.container.background widget
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

--- Margin container with consistent per-side spacing.
-- Defaults all four sides to `SPACING.LARGE` unless overridden.
-- @tparam[opt] table args Configuration:
--   * `margin` (number): default per-side margin
--   * `margins` (table): explicit `{left, right, top, bottom}` table
--   * `left`, `right`, `top`, `bottom` (number): per-side overrides
-- @treturn table A wibox.container.margin widget
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

--- Rounded background container with padding nested inside.
-- Combines `rounded_bg` and `padded`; the padding is the only child
-- of the background.
-- @tparam[opt] table args Same args as `rounded_bg` and `padded`
-- @treturn table A nested background/margin widget
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

--- Build a separator widget (thin colored line).
-- @tparam[opt="horizontal"] string orientation `"horizontal"` or `"vertical"`
-- @tparam[opt] number thickness Line thickness in px (default `beautiful.separator_thickness`)
-- @treturn table A wibox container holding a separator line
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

--- Horizontal layout containing an icon widget followed by a text widget.
-- @tparam table icon_widget Widget to render on the left
-- @tparam table text_widget Widget to render on the right
-- @tparam[opt] number spacing Pixels between the two widgets
-- @treturn table A wibox.layout.fixed.horizontal widget
function container_styles.icon_text_layout(icon_widget, text_widget, spacing)
    return {
        layout = wibox.layout.fixed.horizontal,
        spacing = spacing or ui_constants.SPACING.MEDIUM,
        icon_widget,
        text_widget,
    }
end

return container_styles
