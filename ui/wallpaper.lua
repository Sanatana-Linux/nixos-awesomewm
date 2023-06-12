---@diagnostic disable: undefined-global
--                  __ __
-- .--.--.--.---.-.|  |  |.-----.---.-.-----.-----.----.
-- |  |  |  |  _  ||  |  ||  _  |  _  |  _  |  -__|   _|
-- |________|___._||__|__||   __|___._|   __|_____|__|
--                        |__|        |__|
-- -------------------------------------------------------------------------- --

screen.connect_signal("request::wallpaper", function(s)
    if beautiful.wallpaper then
        gears.wallpaper.maximized(beautiful.wallpaper, s, false, nil)
    end
end)
