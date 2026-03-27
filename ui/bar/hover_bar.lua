-- ui/bar/hover_bar.lua
-- Hover-reveal wibar that slides in from bottom when mouse approaches screen edge.

local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local anim = require("modules.animations")
local gtimer = require("gears.timer")

local hover_bar = {}

-- Configuration constants
local TRIGGER_ZONE_HEIGHT = dpi(3)
local HIDE_DELAY_SECONDS = 3
local ANIMATION_DURATION = 0.25
local BAR_HEIGHT_PRIMARY = dpi(30)
local BAR_HEIGHT_SECONDARY = dpi(40)

function hover_bar.create(args)
    local screen = args.screen
    local bar_height = args.height or BAR_HEIGHT_PRIMARY
    local bar_widget = args.widget
    local is_primary = args.is_primary or false

    local screen_geo = screen.geometry
    local hidden_y = screen_geo.y + screen_geo.height
    local visible_y = screen_geo.y + screen_geo.height - bar_height

    -- State tracking
    local state = {
        is_visible = false,
        is_animating = false,
        hide_timer = nil,
    }

    -- Create the trigger zone (invisible, at bottom of screen)
    local trigger_zone = wibox({
        x = screen_geo.x,
        y = screen_geo.y + screen_geo.height - TRIGGER_ZONE_HEIGHT,
        width = screen_geo.width,
        height = TRIGGER_ZONE_HEIGHT,
        visible = true,
        ontop = false,
        type = "utility",
        bg = "#00000000",
        input_pass_through = false,
    })

    -- Create the bar wibox
    local bar = wibox({
        x = screen_geo.x,
        y = hidden_y,
        width = screen_geo.width,
        height = bar_height,
        visible = true,
        ontop = true,
        type = "utility",
        bg = beautiful.bg .. "99",
        border_width = 0,
        border_color = beautiful.bg .. "66",
        widget = bar_widget,
    })

    -- Clear any struts (ensure no geometry impact)
    bar:struts({ left = 0, right = 0, top = 0, bottom = 0 })

    -- Animation controller reference
    local animation_controller = nil

    -- Helper: cancel hide timer
    local function cancel_hide_timer()
        if state.hide_timer then
            state.hide_timer:stop()
            state.hide_timer = nil
        end
    end

    -- Helper: start hide timer
    local function start_hide_timer()
        cancel_hide_timer()
        state.hide_timer = gtimer({
            timeout = HIDE_DELAY_SECONDS,
            autostart = true,
            single_shot = true,
            callback = function()
                if state.is_visible and not state.is_animating then
                    hover_bar.hide(
                        bar,
                        state,
                        screen_geo,
                        bar_height,
                        animation_controller
                    )
                end
            end,
        })
    end

    -- Helper: animate to position
    local function animate_to(target_y, callback)
        if animation_controller then
            animation_controller.stop()
        end
        state.is_animating = true
        animation_controller = anim.slide_y(bar, {
            start = bar.y,
            target = target_y,
            duration = ANIMATION_DURATION,
            easing = anim.easing.quadratic,
            update = function(pos)
                bar.y = pos
            end,
            complete = function()
                state.is_animating = false
                if callback then
                    callback()
                end
            end,
        })
    end

    -- Trigger zone mouse enter: show bar
    trigger_zone:connect_signal("mouse::enter", function()
        cancel_hide_timer()
        if not state.is_visible then
            state.is_visible = true
            animate_to(visible_y)
        end
    end)

    -- Trigger zone mouse leave: start hide timer
    trigger_zone:connect_signal("mouse::leave", function()
        start_hide_timer()
    end)

    -- Bar mouse enter: cancel hide timer
    bar:connect_signal("mouse::enter", function()
        cancel_hide_timer()
    end)

    -- Bar mouse leave: start hide timer
    bar:connect_signal("mouse::leave", function()
        start_hide_timer()
    end)

    -- Handle screen geometry changes
    screen:connect_signal("property::geometry", function()
        local geo = screen.geometry
        local new_hidden_y = geo.y + geo.height
        local new_visible_y = geo.y + geo.height - bar_height

        trigger_zone.x = geo.x
        trigger_zone.y = geo.y + geo.height - TRIGGER_ZONE_HEIGHT
        trigger_zone.width = geo.width

        bar.x = geo.x
        bar.width = geo.width

        if state.is_visible then
            bar.y = new_visible_y
        else
            bar.y = new_hidden_y
        end
    end)

    return {
        bar = bar,
        trigger_zone = trigger_zone,
        show = function()
            cancel_hide_timer()
            if not state.is_visible then
                state.is_visible = true
                animate_to(visible_y)
            end
        end,
        hide = function()
            cancel_hide_timer()
            if state.is_visible then
                hover_bar.hide(
                    bar,
                    state,
                    screen_geo,
                    bar_height,
                    animation_controller
                )
            end
        end,
        destroy = function()
            cancel_hide_timer()
            if animation_controller then
                animation_controller.stop()
            end
            bar:destroy()
            trigger_zone:destroy()
        end,
    }
end

function hover_bar.hide(bar, state, screen_geo, bar_height, animation_controller)
    local hidden_y = screen_geo.y + screen_geo.height

    if animation_controller then
        animation_controller.stop()
    end

    state.is_animating = true
    animation_controller = anim.slide_y(bar, {
        start = bar.y,
        target = hidden_y,
        duration = ANIMATION_DURATION,
        easing = anim.easing.quadratic,
        update = function(pos)
            bar.y = pos
        end,
        complete = function()
            state.is_animating = false
            state.is_visible = false
        end,
    })
end

return hover_bar
