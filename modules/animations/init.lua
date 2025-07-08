--[[
Animation Utilities Module

This module provides a set of animation utilities for smoothly transitioning values over time.
It includes various easing functions and animation helpers for common UI effects such as sliding,
fading, resizing, and progress updates.

USAGE:

local anim = require("modules.animation")

-- Animate a value from 0 to 100 over 1 second using cubic easing:
local controller = anim.animate{
  start = 0,
  target = 100,
  duration = 1,
  easing = anim.easing.cubic,
  update = function(value, progress)
    print("Current value:", value, "Progress:", progress)
  end,
  complete = function()
    print("Animation complete!")
  end
}

-- Stop, pause, or resume the animation:
controller.stop()
controller.pause()
controller.resume()
controller.set_speed(2) -- Double the speed

-- Slide an element horizontally:
anim.slide(element, { start = 0, target = 200, duration = 0.5 })

-- Slide an element vertically:
anim.slide_y(element, { start = 0, target = 300, duration = 0.5 })

-- Fade an element in/out:
anim.fade(element, { start = 0, target = 1, duration = 0.3 })

-- Animate a progress bar:
anim.progress{ progress_bar = my_bar, start = 0, target = 1, duration = 2 }

-- Resize an element:
anim.resize(element, {
  start_width = 100, target_width = 200,
  start_height = 50, target_height = 100,
  duration = 1,
  on_resize = function(w, h, progress) print(w, h, progress) end
})

DEPENDENCY:
This module requires a timer implementation compatible with the 'gears.timer' API (from AwesomeWM).
Replace 'gears.timer' with your preferred timer if needed.

--]]

local gears = require("gears") -- Ensure you have the gears library available   

local M = {}

local min = math.min
local sin = math.sin
local pi = math.pi
local pow = function(x, y)
    return x ^ y
end
local pi_div_2 = pi / 2
local two_pi = 2 * pi

-- Easing functions for different animation curves
M.easing = {
    linear = function(t)
        return t
    end, -- Linear interpolation
    easin = function(t)
        return t * t
    end, -- Quadratic ease-in
    bounce = function(t) -- Simple bounce effect
        if t < 0.5 then
            return 4 * t * t
        else
            local v = t - 0.75
            return 1 - v * v * 4
        end
    end,
    sinusoidal = function(t) -- Sinusoidal ease-out
        return sin(t * pi_div_2)
    end,
    quadratic = function(t) -- Quadratic ease-out
        local v = 1 - t
        return 1 - v * v
    end,
    cubic = function(t) -- Cubic ease-out
        local v = 1 - t
        return 1 - v * v * v
    end,
    elastic = function(t) -- Elastic ease-out
        local p = 0.3
        return pow(2, -10 * t) * sin((t - p / 4) * two_pi / p) + 1
    end,
    exponential = function(t) -- Exponential ease-out
        if t == 1 then
            return 1
        end
        return 1 - pow(2, -10 * t)
    end,
}

--[[
Main animation function

Params:
  start (number): Starting value (default 0)
  target (number): Target value (default 1)
  duration (number): Animation duration in seconds (default 0.5)
  interval (number): Timer interval in seconds (default 0.02)
  easing (function): Easing function (default quadratic)
  update (function): Called on each update with (value, progress)
  complete (function): Called when animation completes

Returns:
  controller (table): Animation controller with stop, pause, resume, set_speed, get_value
--]]
function M.animate(params)
    local start_value = params.start or 0
    local target_value = params.target or 1
    local duration = params.duration or 0.5
    local interval = params.interval or 0.02
    local easing = params.easing or M.easing.quadratic
    local on_update = params.update or function() end
    local on_complete = params.complete or function() end

    -- Pre-calculate the value difference for optimization
    local value_diff = target_value - start_value

    local time_elapsed = 0
    local current_value = start_value
    local is_paused = false
    local timer

    -- Call initial update
    on_update(start_value, 0)

    -- Timer loop for animation steps
    timer = gears.timer({
        timeout = interval,
        autostart = true,
        callback = function()
            if is_paused then
                return true
            end

            time_elapsed = time_elapsed + interval
            local progress = min(time_elapsed / duration, 1)
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

    -- Animation controller API
    local controller = {
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

    return controller
end

-- Slide an element vertically (animates the 'y' property)
function M.slide_y(element, params)
    params = params or {}
    params.update = params.update or function(pos)
        element.y = pos
    end
    return M.animate(params)
end

-- Slide an element horizontally (animates the 'x' property)
function M.slide(element, params)
    params = params or {}
    params.update = params.update or function(pos)
        element.x = pos
    end
    return M.animate(params)
end

-- Animate a progress bar or value
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

-- Fade an element (animates the 'opacity' property)
function M.fade(element, params)
    params = params or {}
    params.update = params.update
        or function(value)
            element.opacity = value
        end
    return M.animate(params)
end

-- Resize an element (animates width and height)
function M.resize(element, params)
    params = params or {}
    local start_width = params.start_width or element.width
    local target_width = params.target_width or element.width
    local start_height = params.start_height or element.height
    local target_height = params.target_height or element.height

    params.start = 0
    params.target = 1
    params.update = function(progress)
        local width = start_width + (target_width - start_width) * progress
        local height = start_height + (target_height - start_height) * progress
        element.width = width
        element.height = height
        if params.on_resize then
            params.on_resize(width, height, progress)
        end
    end
    return M.animate(params)
end

return M
