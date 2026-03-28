local wibox = require("wibox")
local beautiful = require("beautiful")
local shapes = require("modules.shapes")
local dpi = beautiful.xresources.apply_dpi

local function new(opts)
    opts = opts or {}
    local shape = opts.shape or shapes.rrect(20)
    local bg = opts.bg or beautiful.bg .. "bb"
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