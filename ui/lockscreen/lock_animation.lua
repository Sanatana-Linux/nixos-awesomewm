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

local ANIMATION_DIRECTIONS = { "north", "west", "south", "east" }

--- Linearly interpolate between two `#rrggbb` colors at fraction `t` (0..1).
-- @tparam string a Start color `#rrggbb`
-- @tparam string b End color `#rrggbb`
-- @tparam number t Interpolation fraction in [0, 1]
-- @treturn string Interpolated `#rrggbb` color
-- @local
local function lerp_color(a, b, t)
    local ar = tonumber(a:sub(2, 3), 16)
    local ag = tonumber(a:sub(4, 5), 16)
    local ab = tonumber(a:sub(6, 7), 16)
    local br = tonumber(b:sub(2, 3), 16)
    local bg = tonumber(b:sub(4, 5), 16)
    local bb = tonumber(b:sub(6, 7), 16)
    local r = math.floor(ar + (br - ar) * t)
    local g = math.floor(ag + (bg - ag) * t)
    local bl = math.floor(ab + (bb - ab) * t)
    return string.format("#%02x%02x%02x", r, g, bl)
end

--- 8-step progression from the theme foreground to the theme background.
-- Keypress 1 shows `beautiful.fg`; the 8th keypress shows `beautiful.bg`.
-- Beyond 8 characters the arc stays on the final (bg) color.
-- @local
local fg_color = beautiful.fg or "#f7f1ff"
local bg_color = beautiful.bg or "#1c1c1c"
local ANIMATION_COLORS = {}
for i = 1, 8 do
    ANIMATION_COLORS[i] = lerp_color(fg_color, bg_color, (i - 1) / 7)
end

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

--- Animate one key press: advance or recede the gradient arc on the lock icon.
-- On `"insert"`: increments counter, steps the arc color along the 8-color
-- fg→bg progression, turns icon to key.
-- On `"remove"`: decrements counter, resets arc to grey.
-- Resets entirely when the counter reaches zero.
-- @tparam string operation `"insert"` or `"remove"`
function lock_animation.key_animation(operation)
    local arc_color

    if operation == "insert" then
        characters_entered = characters_entered + 1
        -- Clamp to the last (bg) step once 8+ characters are entered.
        local step = math.min(characters_entered, 8)
        arc_color = ANIMATION_COLORS[step]
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
