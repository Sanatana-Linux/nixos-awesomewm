local anim = require("modules.animation")
local ui_constants = require("modules.ui_constants")

-- Common popup animation patterns
local popup_animations = {}

function popup_animations.slide_in_from_top(popup, final_y, callback)
    local start_y = final_y - ui_constants.ANIMATION.SLIDE_OFFSET
    popup.y = start_y
    popup.opacity = 0
    
    anim.animate({
        start = 0,
        target = 1,
        duration = ui_constants.ANIMATION.DURATION_SHORT,
        easing = anim.easing[ui_constants.ANIMATION.EASING_DEFAULT],
        update = function(progress)
            popup.opacity = progress
            popup.y = start_y + (final_y - start_y) * progress
        end,
        complete = callback,
    })
end

function popup_animations.slide_out_to_top(popup, callback)
    local start_y = popup.y
    local final_y = start_y - ui_constants.ANIMATION.SLIDE_OFFSET
    
    anim.animate({
        start = 1,
        target = 0,
        duration = ui_constants.ANIMATION.DURATION_SHORT,
        easing = anim.easing[ui_constants.ANIMATION.EASING_DEFAULT],
        update = function(progress)
            popup.opacity = progress
            popup.y = start_y + (final_y - start_y) * (1 - progress)
        end,
        complete = function()
            popup.visible = false
            if callback then callback() end
        end,
    })
end

function popup_animations.fade_in(popup, callback)
    popup.opacity = 0
    
    anim.animate({
        start = 0,
        target = 1,
        duration = ui_constants.ANIMATION.DURATION_SHORT,
        easing = anim.easing[ui_constants.ANIMATION.EASING_DEFAULT],
        update = function(progress)
            popup.opacity = progress
        end,
        complete = callback,
    })
end

function popup_animations.fade_out(popup, callback)
    anim.animate({
        start = 1,
        target = 0,
        duration = ui_constants.ANIMATION.DURATION_SHORT,
        easing = anim.easing[ui_constants.ANIMATION.EASING_DEFAULT],
        update = function(progress)
            popup.opacity = progress
        end,
        complete = function()
            popup.visible = false
            if callback then callback() end
        end,
    })
end

return popup_animations