---@diagnostic disable: undefined-global
--- Page container widget.
-- Wraps content in a themed rounded-rectangle background with border
-- and inner margin. Used to wrap each control panel page in a
-- consistent visual frame.
-- @module modules.page_container

local wibox = require("wibox")
local beautiful = require("beautiful")
local shapes = require("modules.style.shapes")
local dpi = beautiful.xresources.apply_dpi
local color_alpha = require("lib.util").color_alpha

--- Build a page container.
-- @tparam[opt] table opts Configuration:
--   * `content` (widget): the inner widget (required for anything visible)
--   * `shape` (function): shape closure (default `shapes.rrect(20)`)
--   * `bg` (string): background color (default `beautiful.bg .. "bb"`)
--   * `border_width` (number): border width in px (default `beautiful.border_width`)
--   * `border_color` (string): border color (default `beautiful.border_color_normal`)
--   * `margins` (number): inner margin in px (default `dpi(12)`)
-- @treturn table A wibox widget wrapping the content
local function new(opts)
    opts = opts or {}
    local shape = opts.shape or shapes.rrect(20)
    local bg = opts.bg or color_alpha(beautiful.bg, "bb")
    local border_width = opts.border_width or beautiful.border_width
    local border_color = opts.border_color or beautiful.border_color_normal
    local margins = opts.margins or dpi(12)
    local content = opts.content

    return wibox.widget({
        widget = wibox.container.background,
        bg = bg,
        shape = shape,
        border_width = border_width,
        border_color = border_color,
        {
            widget = wibox.container.margin,
            margins = margins,
            content,
        },
    })
end

return setmetatable({}, { __call = new })
