return function(width)
    return wibox.widget({
        forced_width = width,
        layout = wibox.layout.fixed.vertical,
    })
end
