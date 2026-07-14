--[[
    hover_button - A customizable AwesomeWM widget for buttons with hover effects.

    Provides a button widget with configurable background/foreground colors,
    border colors, and label. Colors and borders change on mouse hover and press.

    Usage:
        local hover_button = require("modules.hover_button")
        local btn = hover_button {
            label = "Click Me",
            bg_normal = "#222222",
            bg_hover = "#444444",
            fg_normal = "#ffffff",
            fg_hover = "#ff0000",
            border_color = "#333333",
            border_hover = "#ff0000",
            shape = gears.shape.rounded_rect,
            forced_width = 100,
            forced_height = 40,
            margins = 8,
        }

    Methods:
        :set_label(label)         -- Set button label text
        :set_bg_normal(color)     -- Set normal background color
        :set_fg_normal(color)     -- Set normal foreground color
        :set_bg_hover(color)      -- Set hover background color
        :set_fg_hover(color)      -- Set hover foreground color

    Signals:
        mouse::enter              -- Applies hover colors/borders
        mouse::leave              -- Reverts to normal colors/borders
        button::press             -- Reverts to normal colors/borders
]]

--- hover_button — themed button with hover effects.
-- Builds a `wibox` with the standard normal/hover color states. Color/border
-- setters (`set_bg_normal`, `set_fg_normal`, `set_bg_hover`, `set_fg_hover`)
-- mutate the button's `_private` state and apply normal-state colors
-- immediately (hover colors are picked up on the next `mouse::enter`).
-- The label can be updated at runtime via `set_label`.
-- @module modules.hover_button

local wibox = require("wibox")
local gtable = require("gears.table")
local gcolor = require("gears.color")
local beautiful = require("beautiful")

-- Button methods table
local button = {}

--- Set the button label text.
-- @tparam string label Markup/text for the label
function button:set_label(label)
    local label_widget = self:get_children_by_id("label-role")
    if label_widget then
        label_widget[1]:set_markup(label)
    end
end

--- Set the normal background color and apply it immediately.
-- @tparam string color Background color
function button:set_bg_normal(color)
    local wp = self._private
    wp.bg_normal = color
    self:set_bg(wp.bg_normal)
end

--- Set the normal foreground color and apply it immediately.
-- @tparam string color Foreground color
function button:set_fg_normal(color)
    local wp = self._private
    wp.fg_normal = color
    self:set_fg(wp.fg_normal)
end

--- Set the hover background color (applied on next `mouse::enter`).
-- @tparam string color Background color for hover state
function button:set_bg_hover(color)
    local wp = self._private
    wp.bg_hover = color
end

--- Set the hover foreground color (applied on next `mouse::enter`).
-- @tparam string color Foreground color for hover state
function button:set_fg_hover(color)
    local wp = self._private
    wp.fg_hover = color
end

--- Create a new hover button widget.
-- @tparam[opt] table args Widget configuration options:
--   * `label` (string): label text (or pass `child_widget` to override)
--   * `child_widget` (table): custom inner widget (default: textbox with `label`)
--   * `font` (string): label font (default `beautiful.font`)
--   * `align` (string): label alignment (default "center")
--   * `bg_normal`, `bg_hover` (string): background colors
--   * `fg_normal`, `fg_hover` (string): foreground colors
--   * `border_color` (string): idle border (alias `border_color_normal`)
--   * `border_hover` (string): hovered border
--   * `border_width` (number): border width
--   * `shape` (function): shape closure
--   * `forced_width`, `forced_height` (number): widget dimensions
--   * `margins` (number|table): inner margins
--   * `buttons` (table): awful.button bindings
--   * `icon_source` (string): image path; auto-recoloured on hover
--   * `icon_normal_color`, `icon_hover_color` (string): icon colors
-- @treturn table A wibox widget with `set_label`, `set_bg_normal`, etc.
local function new(args)
    args = args or {}

    local content_widget = args.child_widget
        or {
            id = "label-role",
            widget = wibox.widget.textbox,
            font = args.font or beautiful.font,
            align = args.align or "center",
            markup = args.label or "",
        }

    local ret = wibox.widget({
        widget = wibox.container.background,
        shape = args.shape,
        buttons = args.buttons,
        forced_width = args.forced_width,
        forced_height = args.forced_height,
        border_width = args.border_width or 0,
        border_color = args.border_color_normal
            or beautiful.bg_urg
            or "#3d3d3d",
        bg = args.bg_normal or beautiful.bg_gradient_button,
        fg = args.fg_normal or beautiful.fg or "#ffffff",
        {
            widget = wibox.container.margin,
            margins = args.margins or 0,
            content_widget,
        },
    })

    gtable.crush(ret, button, true)
    local wp = ret._private

    wp.border_normal = args.border_color or beautiful.bg_urg or "#3d3d3d"
    wp.border_hover = args.border_hover or beautiful.fg_alt or "#ffffff"
    wp.bg_hover = args.bg_hover or beautiful.bg_gradient_recessed
    wp.fg_hover = args.fg_hover or beautiful.fg or "#ffffff"
    wp.bg_normal = args.bg_normal or beautiful.bg_gradient_button
    wp.fg_normal = args.fg_normal or beautiful.fg or "#ffffff"
    wp.icon_source = args.icon_source
    wp.icon_normal_color = args.icon_normal_color
    wp.icon_hover_color = args.icon_hover_color

    local function recolor_icons(w, color)
        if not wp.icon_source or not color then
            return
        end
        for _, child in ipairs(w:get_all_children()) do
            if child.set_image then
                child.image = gcolor.recolor_image(wp.icon_source, color)
            end
        end
    end

    -- Mouse hover: apply hover colors/borders
    ret:connect_signal("mouse::enter", function(w)
        w:set_border_color(wp.border_hover)
        w:set_bg(wp.bg_hover)
        w:set_fg(wp.fg_hover)
        recolor_icons(w, wp.icon_hover_color)
    end)

    -- Mouse leave: revert to normal colors/borders
    ret:connect_signal("mouse::leave", function(w)
        w:set_border_color(wp.border_normal)
        w:set_bg(wp.bg_normal)
        w:set_fg(wp.fg_normal)
        recolor_icons(w, wp.icon_normal_color)
    end)

    -- Button press: revert to normal colors/borders
    ret:connect_signal("button::press", function(w)
        w:set_border_color(wp.border_normal)
        w:set_bg(wp.bg_normal)
        w:set_fg(wp.fg_normal)
        recolor_icons(w, wp.icon_normal_color)
    end)

    return ret
end

return setmetatable({
    new = new,
}, {
    __call = function(_, ...)
        return new(...)
    end,
})
