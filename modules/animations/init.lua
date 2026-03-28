--[[
Animation Module

Provides smooth value transitions over time using various easing functions.
Built on gears.timer for AwesomeWM integration.

QUICK START:
    local anim = require("modules.animations")

    -- Animate a value from 0 to 100 over 1 second
    anim.animate({
        start = 0,
        target = 100,
        duration = 1,
        update = function(value)
            print("Current: " .. value)
        end,
    })

HELPER FUNCTIONS:
    anim.slide_y(wibox, {...})   -- Animate vertical position
    anim.slide(wibox, {...})      -- Animate horizontal position
    anim.fade(wibox, {...})       -- Animate opacity (0-1)
    anim.resize(wibox, {...})     -- Animate width/height

EASING FUNCTIONS:
    linear, quadratic, cubic, sinusoidal, exponential, elastic, bounce

CONTROLLER METHODS:
    controller.stop()        -- Stop animation
    controller.pause()       -- Pause animation
    controller.resume()      -- Resume paused animation
    controller.set_speed(n)  -- Adjust speed (2 = double speed)
    controller.get_value()   -- Get current animated value
--]]

local gears = require("gears")

local M = {}

-- ============================================================================
-- EASING FUNCTIONS
-- ============================================================================

M.easing = {}

function M.easing.linear(t)
    return t
end

function M.easing.easin(t)
    return t * t
end

function M.easing.quadratic(t)
    local v = 1 - t
    return 1 - v * v
end

function M.easing.cubic(t)
    local v = 1 - t
    return 1 - v * v * v
end

function M.easing.sinusoidal(t)
    return math.sin(t * math.pi / 2)
end

function M.easing.exponential(t)
    if t == 1 then
        return 1
    end
    return 1 - 2 ^ (-10 * t)
end

function M.easing.elastic(t)
    local p = 0.3
    return 2 ^ (-10 * t) * math.sin((t - p / 4) * (2 * math.pi) / p) + 1
end

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

function M.slide_y(element, params)
    params = params or {}
    params.update = params.update or function(pos)
        element.y = pos
    end
    return M.animate(params)
end

function M.slide(element, params)
    params = params or {}
    params.update = params.update or function(pos)
        element.x = pos
    end
    return M.animate(params)
end

function M.fade(element, params)
    params = params or {}
    params.update = params.update or function(value)
        element.opacity = value
    end
    return M.animate(params)
end

function M.progress(params)
    params = params or {}
    params.update = params.update or function(value)
        if params.progress_bar then
            params.progress_bar:set_value(value)
        end
    end
    return M.animate(params)
end

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
