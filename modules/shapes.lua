local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local M = {}

function M.rrect(radius)
    return beautiful.rrect(dpi(radius))
end

function M.circle(radius)
    return beautiful.crcl(radius)
end

function M.rbar()
    return beautiful.rbar()
end

return M