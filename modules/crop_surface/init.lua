---@diagnostic disable: undefined-global
--- Crop a Cairo surface to a given aspect ratio, centering the crop.
-- If the source already has the requested aspect ratio, returns the
-- input surface unchanged. Otherwise, crops symmetrically and
-- returns a new ImageSurface with the requested aspect ratio.
-- @tparam number ratio Desired aspect ratio (width / height)
-- @tparam cairo.Surface surf Source Cairo surface
-- @treturn cairo.Surface Cropped Cairo surface (or the input when ratios match)
-- @module modules.crop_surface
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
