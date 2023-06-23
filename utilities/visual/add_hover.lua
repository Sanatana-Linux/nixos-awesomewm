-- add hover support to wibox.container.background-based elements

return function(element, bg, hbg)
    element:connect_signal("mouse::enter", function(self)
        self.bg = hbg
    end)
    element:connect_signal("mouse::leave", function(self)
        self.bg = bg
    end)

    return element
end
