--[[
Button Styles - Shared button styling presets

Provides consistent button styling across the UI. Use these presets
to ensure buttons match the bar/control panel button aesthetic.

Usage:
local button_styles = require("modules.button_styles")
local btn = modules.hover_button(button_styles.icon_button({
    icon = "path/to/icon.svg",
    size = dpi(22),
}))
]]

local beautiful = require("beautiful")
local wibox = require("wibox")
local shapes = require("modules.shapes.init")
local dpi = beautiful.xresources.apply_dpi

local M = {}

local BASE_STYLE = {
    bg_normal = beautiful.bg_gradient_button,
    bg_hover = beautiful.bg_gradient_button_alt,
    fg_normal = beautiful.fg,
    fg_hover = beautiful.fg,
}

local ICON_BUTTON_RADIUS = 8

function M.icon_button(opts)
    opts = opts or {}
    local size = opts.size or dpi(22)
    local radius = opts.radius or ICON_BUTTON_RADIUS

    return {
        bg_normal = BASE_STYLE.bg_normal,
        bg_hover = BASE_STYLE.bg_hover,
        fg_normal = BASE_STYLE.fg,
        fg_hover = BASE_STYLE.fg,
        shape = shapes.rrect(radius),
        child_widget = {
            widget = wibox.container.margin,
            margins = opts.margins or dpi(2),
            {
                widget = wibox.widget.imagebox,
                image = opts.icon,
                forced_width = size,
                forced_height = size,
            },
        },
    }
end

function M.text_button(opts)
    opts = opts or {}
    local radius = opts.radius or ICON_BUTTON_RADIUS

    return {
        bg_normal = BASE_STYLE.bg_normal,
        bg_hover = BASE_STYLE.bg_hover,
        fg_normal = BASE_STYLE.fg,
        fg_hover = BASE_STYLE.fg,
        shape = shapes.rrect(radius),
        label = opts.label or "",
    }
end

M.BASE_STYLE = BASE_STYLE
M.ICON_BUTTON_RADIUS = ICON_BUTTON_RADIUS

return M
