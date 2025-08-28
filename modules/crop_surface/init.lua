--[[
    Crop a Cairo surface to a specified aspect ratio, centering the crop.

    @param ratio (number) Desired aspect ratio (width / height).
    @param surf (cairo.Surface) Source Cairo surface to crop.

    @return (cairo.Surface) Cropped Cairo surface with the specified aspect ratio.
--]]

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local cairo = require("lgi").cairo
local gmatrix = require("gears.matrix")
local json = require("lib.json")
local wibox = require("wibox")

--- Crop a Cairo surface to a given aspect ratio, centering the crop.
-- @param ratio Desired aspect ratio (width / height).
-- @param surf Source Cairo surface.
-- @return Cropped Cairo surface.
return function(ratio, surf)
    local old_w, old_h = gears.surface.get_size(surf)
    local old_ratio = old_w / old_h
    if old_ratio == ratio then
        return surf
    end

    local new_h = old_h
    local new_w = old_w
    local offset_h, offset_w = 0, 0
    -- Calculate new dimensions and offsets for cropping
    if old_ratio < ratio then
        new_h = math.ceil(old_w * (1 / ratio))
        offset_h = math.ceil((old_h - new_h) / 2)
    else
        new_w = math.ceil(old_h * ratio)
        offset_w = math.ceil((old_w - new_w) / 2)
    end

    local out_surf = cairo.ImageSurface(cairo.Format.ARGB32, new_w, new_h)
    local cr = cairo.Context(out_surf)
    cr:set_source_surface(surf, -offset_w, -offset_h)
    cr.operator = cairo.Operator.SOURCE
    cr:paint()

    return out_surf
end
