--- Lock screen animation widget.
-- Animated lock icon with rotating coloured arc that responds to key presses.
-- Shows a rainbow arc segment on each key press, cycling through directions
-- and colours, and resets on auth failure or empty input.
-- @module ui.lockscreen.lock_animation

local beautiful = require("beautiful")
local gshape = require("gears.shape")
local wibox = require("wibox")
local gcolor = require("gears.color")
local gfs = require("gears.filesystem")
local dpi = beautiful.xresources.apply_dpi

-- Use local SVG assets for better modularity
local assets_dir = gfs.get_configuration_dir() .. "ui/lockscreen/assets/"
local LOCK_ICON_PATH = assets_dir .. "lock.svg"
local KEY_ICON_PATH = assets_dir .. "key.svg"

local ANIMATION_COLORS = { -- Rainbow sequence 🌈
    beautiful.red or "#fc618d",
    beautiful.magenta or "#c678dd",
    beautiful.accent or "#61afef",
    beautiful.cyan or "#56b6c2",
    beautiful.green or "#98c379",
    beautiful.yellow or "#e5c07b",
}

local ANIMATION_DIRECTIONS = { "north", "west", "south", "east" }

local characters_entered = 0

local icon = wibox.widget({
    -- Set forced size to prevent flickering when the icon rotates
    forced_height = dpi(80),
    forced_width = dpi(80),
    image = gcolor.recolor_image(
        LOCK_ICON_PATH,
        beautiful.light_black or "#888888"
    ),
    resize = true,
    widget = wibox.widget.imagebox,
})

local arc = wibox.widget({
    bg = "transparent",
    forced_width = dpi(80),
    forced_height = dpi(80),
    shape = function(cr, width, height)
        -- Use consistent positioning - arc should match icon bounds
        gshape.arc(cr, width, height, dpi(5), 0, math.pi / 2, true, true)
    end,
    widget = wibox.container.background,
})

local rotate = wibox.widget({
    {
        arc,
        widget = wibox.container.place, -- Center the arc
    },
    widget = wibox.container.rotate,
})

local lock_animation = wibox.widget({
    {
        rotate,
        widget = wibox.container.place, -- Center the rotated arc
    },
    {
        icon,
        widget = wibox.container.place, -- Center the icon
    },
    layout = wibox.layout.stack,
})

--- Reset the animation to idle state (grey lock icon, transparent arc, north).
function lock_animation.reset()
    icon.image =
        gcolor.recolor_image(LOCK_ICON_PATH, beautiful.light_black or "#888888")
    rotate.direction = "north"
    arc.bg = "transparent"

    characters_entered = 0
end

--- Show authentication failure (red lock icon, reset arc and character count).
function lock_animation.fail()
    icon.image =
        gcolor.recolor_image(LOCK_ICON_PATH, beautiful.red or "#fc618d")
    rotate.direction = "north"
    arc.bg = "transparent"

    characters_entered = 0
end

--- Animate one key press: advance or recede the rainbow arc on the lock icon.
-- On `"insert"`: increments counter, cycles arc colour, turns icon to key.
-- On `"remove"`: decrements counter, resets arc to grey.
-- Resets entirely when the counter reaches zero.
-- @tparam string operation `"insert"` or `"remove"`
function lock_animation.key_animation(operation)
    local arc_color

    if operation == "insert" then
        characters_entered = characters_entered + 1
        arc_color = ANIMATION_COLORS[(characters_entered % 6) + 1]
        icon.image = gcolor.recolor_image(KEY_ICON_PATH, arc_color)
    elseif characters_entered > 0 then
        characters_entered = characters_entered - 1
        arc_color = beautiful.light_black or "#888888"
    end

    if characters_entered == 0 then
        lock_animation.reset()
        return
    end

    arc.bg = arc_color
    rotate.direction = ANIMATION_DIRECTIONS[(characters_entered % 4) + 1]
end

return lock_animation
