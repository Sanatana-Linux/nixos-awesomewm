---@diagnostic disable: undefined-global
--- Button styling presets.
-- Pre-configured style tables used by `modules.hover_button` to
-- keep visual consistency across the bar, control panel, and
-- popups. Each preset returns a plain table of style hints.
-- @module modules.button_styles

local beautiful = require("beautiful")
local wibox = require("wibox")
local shapes = require("modules.shapes.init")
local dpi = beautiful.xresources.apply_dpi

local M = {}

-- Base style shared by every preset. Pulls colors from beautiful.
-- @table BASE_STYLE
local BASE_STYLE = {
    bg_normal = beautiful.bg_gradient_button,
    bg_hover = beautiful.bg_gradient_button_alt,
    fg_normal = beautiful.fg,
    fg_hover = beautiful.fg,
}

--- Default corner radius for icon/text buttons.
M.ICON_BUTTON_RADIUS = 8

--- Build a style preset for an icon-only button.
-- @tparam[opt] table opts Configuration:
--   * `icon` (string): image path or markup
--   * `size` (number): image size in pixels (default `dpi(22)`)
--   * `radius` (number): corner radius (default `ICON_BUTTON_RADIUS`)
--   * `margins` (number): inner margins (default `dpi(2)`)
-- @treturn table Style table consumable by `hover_button`
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

--- Build a style preset for a text-only button.
-- @tparam[opt] table opts Configuration:
--   * `label` (string): button label
--   * `radius` (number): corner radius (default `ICON_BUTTON_RADIUS`)
-- @treturn table Style table consumable by `hover_button`
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
