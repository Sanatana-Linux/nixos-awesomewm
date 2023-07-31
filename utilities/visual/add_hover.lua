-- @param element widget - must be a `widget = wibox.container.background` widget for this to work
-- @param bg string - normal background color or pattern
-- @param hbg string - color or pattern for when widget is hovered

return function(element, bg, hbg)
    element:connect_signal("mouse::enter", function(self)
        self.bg = hbg
    end)
    element:connect_signal("mouse::leave", function(self)
        self.bg = bg
    end)

    return element
end
