--- Animation module.
-- Smooth value transitions over time using various easing functions.
-- Built on `gears.timer` for AwesomeWM integration.
--
-- Quick start:
--     local anim = require("modules.infra.animations")
--     anim.animate({ start = 0, target = 100, duration = 1,
--                    update = function(v) print(v) end })
-- @module modules.animations

local gears = require("gears")

local M = {}

-- Easing functions: all take a progress value t in [0, 1] and return
-- the eased value (also in [0, 1]). Used as `params.easing` in `animate`.

--- @table M.easing
M.easing = {}

--- Linear easing (no acceleration).
-- @tparam number t Progress 0..1
-- @treturn number Eased value
function M.easing.linear(t)
    return t
end

--- Quadratic ease-in (slow start).
-- @tparam number t Progress 0..1
-- @treturn number Eased value
function M.easing.easin(t)
    return t * t
end

--- Quadratic ease-out (slow end).
-- @tparam number t Progress 0..1
-- @treturn number Eased value
function M.easing.quadratic(t)
    local v = 1 - t
    return 1 - v * v
end

--- Cubic ease-out.
-- @tparam number t Progress 0..1
-- @treturn number Eased value
function M.easing.cubic(t)
    local v = 1 - t
    return 1 - v * v * v
end

--- Sinusoidal ease-out (smooth decel).
-- @tparam number t Progress 0..1
-- @treturn number Eased value
function M.easing.sinusoidal(t)
    return math.sin(t * math.pi / 2)
end

--- Exponential ease-out (sharp decel).
-- @tparam number t Progress 0..1
-- @treturn number Eased value
function M.easing.exponential(t)
    if t == 1 then
        return 1
    end
    return 1 - 2 ^ (-10 * t)
end

--- Elastic ease-out (overshoot + oscillate).
-- @tparam number t Progress 0..1
-- @treturn number Eased value
function M.easing.elastic(t)
    local p = 0.3
    return 2 ^ (-10 * t) * math.sin((t - p / 4) * (2 * math.pi) / p) + 1
end

--- Bounce ease-out (squashy decel).
-- @tparam number t Progress 0..1
-- @treturn number Eased value
function M.easing.bounce(t)
    if t < 0.5 then
        return 4 * t * t
    else
        local v = t - 0.75
        return 1 - v * v * 4
    end
end

-- ============================================================================
-- CORE ANIMATION FUNCTION
-- ============================================================================

--- Animate a value from `start` to `target` over `duration` seconds.
-- @tparam table params Animation spec
-- @tparam number params.start Starting value (default 0)
-- @tparam number params.target Ending value (default 1)
-- @tparam number params.duration Total duration in seconds (default 0.5)
-- @tparam number params.interval Tick interval in seconds (default 0.02)
-- @tparam function params.easing Easing function from `M.easing` (default `quadratic`)
-- @tparam function params.update Called every tick with the current value
-- @tparam function params.complete Called once when the animation ends
-- @treturn table Animation controller with `stop()` / `pause()` / `resume()` / `set_speed(n)` / `get_value()`
function M.animate(params)
    local start_value = params.start or 0
    local target_value = params.target or 1
    local duration = params.duration or 0.5
    local interval = params.interval or 0.02
    local easing = params.easing or M.easing.quadratic
    local on_update = params.update or function() end
    local on_complete = params.complete or function() end

    local value_diff = target_value - start_value
    local time_elapsed = 0
    local current_value = start_value
    local is_paused = false
    local timer = nil

    on_update(start_value, 0)

    timer = gears.timer({
        timeout = interval,
        autostart = true,
        callback = function()
            if is_paused then
                return true
            end

            time_elapsed = time_elapsed + interval
            local progress = math.min(time_elapsed / duration, 1)
            local eased_progress = easing(progress)
            current_value = start_value + value_diff * eased_progress

            on_update(current_value, progress)

            if progress >= 1 then
                timer:stop()
                timer = nil
                on_complete()
                return false
            end

            return true
        end,
    })

    return {
        stop = function()
            if timer then
                timer:stop()
                timer = nil
            end
        end,
        pause = function()
            is_paused = true
        end,
        resume = function()
            is_paused = false
        end,
        set_speed = function(speed_multiplier)
            if timer then
                timer.timeout = interval / (speed_multiplier or 1)
            end
        end,
        get_value = function()
            return current_value
        end,
    }
end

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

--- Animate an element's `y` (vertical position).
-- @tparam table element Target element with a writable `.y` field
-- @tparam table params Animation params (see `animate`); missing `update` is auto-filled
-- @treturn table Animation controller
function M.slide_y(element, params)
    params = params or {}
    params.update = params.update
        or function(pos)
            element.y = pos
        end
    return M.animate(params)
end

--- Animate an element's `x` (horizontal position).
-- @tparam table element Target element with a writable `.x` field
-- @tparam table params Animation params (see `animate`); missing `update` is auto-filled
-- @treturn table Animation controller
function M.slide(element, params)
    params = params or {}
    params.update = params.update
        or function(pos)
            element.x = pos
        end
    return M.animate(params)
end

--- Animate an element's `opacity` (0..1).
-- @tparam table element Target element with a writable `.opacity` field
-- @tparam table params Animation params (see `animate`); missing `update` is auto-filled
-- @treturn table Animation controller
function M.fade(element, params)
    params = params or {}
    params.update = params.update
        or function(value)
            element.opacity = value
        end
    return M.animate(params)
end

--- Animate a progress value through `params.progress_bar:set_value(v)`.
-- If `params.progress_bar` is set, the default `update` calls
-- `:set_value` on it. Override `update` to customise.
-- @tparam table params Animation params (see `animate`); missing `update` is auto-filled
-- @treturn table Animation controller
function M.progress(params)
    params = params or {}
    params.update = params.update
        or function(value)
            if params.progress_bar then
                params.progress_bar:set_value(value)
            end
        end
    return M.animate(params)
end

--- Animate an element's `width` and `height` simultaneously.
-- `params.start_width`/`target_width` (or `params.start_height`/...)
-- default to the current element size.
-- @tparam table element Target element with writable `.width`/`.height`
-- @tparam table params Animation params:
--   * `start_width`, `target_width` (default: element.width)
--   * `start_height`, `target_height` (default: element.height)
--   * `on_resize(width, height, progress)`: extra callback per tick
-- @treturn table Animation controller
function M.resize(element, params)
    params = params or {}
    local start_width = params.start_width or element.width
    local target_width = params.target_width or element.width
    local start_height = params.start_height or element.height
    local target_height = params.target_height or element.height
    local on_resize = params.on_resize or function() end

    params.start = 0
    params.target = 1
    params.update = function(progress)
        local width = start_width + (target_width - start_width) * progress
        local height = start_height + (target_height - start_height) * progress
        element.width = width
        element.height = height
        on_resize(width, height, progress)
    end

    return M.animate(params)
end

return M
