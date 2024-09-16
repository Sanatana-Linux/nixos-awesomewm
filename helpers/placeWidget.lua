return function(widget)
    if beautiful.barDir == "left" then
        awful.placement.bottom_left(
            widget,
            { honor_workarea = true, margins = beautiful.useless_gap * 2 }
        )
    elseif beautiful.barDir == "right" then
        awful.placement.bottom_right(
            widget,
            { honor_workarea = true, margins = beautiful.useless_gap * 2 }
        )
    elseif beautiful.barDir == "bottom" then
        awful.placement.bottom(
            widget,
            { honor_workarea = true, margins = beautiful.useless_gap * 2 }
        )
    elseif beautiful.barDir == "top" then
        awful.placement.top(
            widget,
            { honor_workarea = true, margins = beautiful.useless_gap * 2 }
        )
    end
end
