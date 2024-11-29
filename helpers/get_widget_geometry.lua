-- helpers/get_widget_geometry.lua
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local cairo = require("lgi").cairo
local gmatrix = require("gears.matrix")
local json = require("mods.json")
local wibox = require("wibox")

local function get_widget_geometry(_hierarchy, widget)
    local width, height = _hierarchy:get_size()
    if _hierarchy:get_widget() == widget then
        -- Get the extents of this widget in the device space
        local x, y, w, h = gmatrix.transform_rectangle(
            _hierarchy:get_matrix_to_device(),
            0,
            0,
            width,
            height
        )
        return { x = x, y = y, width = w, height = h, hierarchy = _hierarchy }
    end

    for _, child in ipairs(_hierarchy:get_children()) do
        local ret = get_widget_geometry(child, widget)
        if ret then
            return ret
        end
    end
end

return function(wibox, widget)
    return get_widget_geometry(wibox._drawable._widget_hierarchy, widget)
end
