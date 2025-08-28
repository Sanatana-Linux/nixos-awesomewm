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

local wibox = require("wibox")
local gtable = require("gears.table")
local beautiful = require("beautiful")

-- Button methods table
local button = {}

--- Set the button label text.
-- @param label (string) Markup/text for the label.
function button:set_label(label)
    local label_widget = self:get_children_by_id("label-role")
    if label_widget then
        label_widget[1]:set_markup(label)
    end
end

--- Set the normal background color and apply it immediately.
-- @param color (string) Background color.
function button:set_bg_normal(color)
    local wp = self._private
    wp.bg_normal = color
    self:set_bg(wp.bg_normal)
end

--- Set the normal foreground color and apply it immediately.
-- @param color (string) Foreground color.
function button:set_fg_normal(color)
    local wp = self._private
    wp.fg_normal = color
    self:set_fg(wp.fg_normal)
end

--- Set the hover background color.
-- @param color (string) Background color for hover state.
function button:set_bg_hover(color)
    local wp = self._private
    wp.bg_hover = color
end

--- Set the hover foreground color.
-- @param color (string) Foreground color for hover state.
function button:set_fg_hover(color)
    local wp = self._private
    wp.fg_hover = color
end

--- Create a new hover button widget.
-- @param args (table) Widget configuration options.
-- @return wibox.widget Widget instance.
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

    -- Mouse hover: apply hover colors/borders
    ret:connect_signal("mouse::enter", function(w)
        w:set_border_color(wp.border_hover)
        w:set_bg(wp.bg_hover)
        w:set_fg(wp.fg_hover)
    end)

    -- Mouse leave: revert to normal colors/borders
    ret:connect_signal("mouse::leave", function(w)
        w:set_border_color(wp.border_normal)
        w:set_bg(wp.bg_normal)
        w:set_fg(wp.fg_normal)
    end)

    -- Button press: revert to normal colors/borders
    ret:connect_signal("button::press", function(w)
        w:set_border_color(wp.border_normal)
        w:set_bg(wp.bg_normal)
        w:set_fg(wp.fg_normal)
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
