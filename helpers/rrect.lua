return  function(radius)
    radius = radius or dpi(4)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end
