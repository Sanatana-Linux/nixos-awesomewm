--- Wallpaper widget.
-- Constructed via `wallpaper(s)` (callable metatable) and added as the
-- `screen.wallpaper` widget for every screen by `ui/init.lua`.
-- Falls back to a `bg_alt`-colored background until an image is set.
-- @module ui.wallpaper

local awful = require("awful")
local wibox = require("wibox")
local gtable = require("gears.table")
local beautiful = require("beautiful")
local imagebox = require("modules.widgets.imagebox")

local wallpaper = {}

--- Set a new image as the wallpaper and repaint the screen.
-- @tparam string new_image Absolute path to the image file
function wallpaper:set_image(new_image)
    if not new_image then
        return
    end
    self:set_widget({
        widget = imagebox,
        resize = true,
        valign = "center",
        halign = "center",
        horizontal_fit_policy = "cover",
        vertical_fit_policy = "cover",
        image = new_image,
    })
    self:repaint()
end

--- Clear the image and fall back to a `bg_alt`-colored background.
function wallpaper:unset()
    self:set_widget({
        widget = wibox.container.background,
        bg = beautiful.bg_alt,
    })
    self:repaint()
end

--- Construct the per-screen wallpaper widget.
-- Initial widget is a `bg_alt`-colored background; the image
-- gets swapped in via `:set_image(path)`.
-- @tparam screen s The screen this wallpaper is bound to
-- @treturn table A wallpaper instance with set_image/unset methods
local function new(s)
    local ret = awful.wallpaper({
        screen = s,
        widget = {
            widget = wibox.container.background,
            bg = beautiful.bg_alt,
        },
    })

    gtable.crush(ret, wallpaper, true)
    return ret
end

return setmetatable({
    new = new,
}, {
    __call = function(_, ...)
        return new(...)
    end,
})
