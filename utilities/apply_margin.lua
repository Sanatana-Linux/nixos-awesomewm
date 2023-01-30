local wibox = require('wibox')
return function(widget, margins, top, bottom, right, left)
    return wibox.widget {
        widget,
        margins = margins,
        left = left,
        right = right,
        top = top,
        bottom = bottom,
        widget = wibox.container.margin,
    }
end
