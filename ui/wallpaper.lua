-- Wallpaper setter using wallpaper defined in themes/theme.lua

---@diagnostic disable: undefined-global

screen.connect_signal("request::wallpaper", function(s)
    if beautiful.wallpaper then
        gears.wallpaper.maximized(beautiful.wallpaper, s, false, nil)
    end
end)
