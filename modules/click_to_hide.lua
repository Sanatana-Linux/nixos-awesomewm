-- Centralized popup management module
-- Handles click-to-hide, escape key, exclusive popups, blur backdrop, and consistent behavior

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local backdrop = require("modules.backdrop")

local popup_manager = {}

-- Track all registered popups
local registered_popups = {}
local active_popup = nil

-- Global escape key handler
local escape_grabber = nil

local function hide_all_popups()
    for popup, data in pairs(registered_popups) do
        if popup.visible and data.hide_function then
            data.hide_function()
        end
    end
    active_popup = nil
    backdrop.hide() -- Hide backdrop when all popups are closed
end

local function setup_escape_key()
    -- Use the simple keygrabber.run approach
    return function()
        escape_grabber = awful.keygrabber.run(function(_, key, event)
            if event == "press" and key == "Escape" then
                hide_all_popups()
                if escape_grabber then
                    awful.keygrabber.stop(escape_grabber)
                    escape_grabber = nil
                end
            end
        end)
    end
end

local function start_escape_listener()
    if not escape_grabber then
        local start_grabber = setup_escape_key()
        start_grabber()
    end
end

local function stop_escape_listener()
    if escape_grabber then
        awful.keygrabber.stop(escape_grabber)
        escape_grabber = nil
    end
end

-- Enhanced click-to-hide with exclusive popup support
local function click_to_hide(widget, hide_fct, options)
    options = options or {}
    local outside_only = options.outside_only or false
    local exclusive = options.exclusive ~= false -- default true
    local disable_escape = options.disable_escape or false

    hide_fct = hide_fct
        or function(object)
            if outside_only and object == widget then
                return
            end
            widget.visible = false
        end

    -- Register this popup
    registered_popups[widget] = {
        hide_function = hide_fct,
        exclusive = exclusive,
        outside_only = outside_only,
        disable_escape = disable_escape,
    }

    local click_bind = awful.button({}, 1, function(object)
        hide_fct(object)
    end)

    -- Handle visibility changes
    widget:connect_signal("property::visible", function(w)
        if not w.visible then
            -- Popup is being hidden
            wibox.disconnect_signal("button::press", hide_fct)
            client.disconnect_signal("button::press", hide_fct)
            awful.mouse.remove_global_mousebinding(click_bind)
            
            if active_popup == widget then
                active_popup = nil
                stop_escape_listener()
                
                -- Check if any other popups are still visible
                local any_visible = false
                for popup, _ in pairs(registered_popups) do
                    if popup ~= widget and popup.visible then
                        any_visible = true
                        break
                    end
                end
                
                -- Hide backdrop only if no popups are visible
                if not any_visible then
                    backdrop.hide()
                end
            end
        else
            -- Popup is being shown
            if exclusive then
                -- Hide other popups first
                for popup, data in pairs(registered_popups) do
                    if popup ~= widget and popup.visible and data.exclusive then
                        data.hide_function()
                    end
                end
            end
            
            active_popup = widget
            
            -- Only start escape listener if not disabled for this widget
            local data = registered_popups[widget]
            if not data.disable_escape then
                start_escape_listener()
            end
            
            -- Show backdrop with blur effect
            backdrop.show(widget)
            
            -- Set up click-to-hide bindings
            awful.mouse.append_global_mousebinding(click_bind)
            client.connect_signal("button::press", hide_fct)
            wibox.connect_signal("button::press", hide_fct)
        end
    end)

    -- Clean up when widget is destroyed
    widget:connect_signal("widget::destroyed", function()
        registered_popups[widget] = nil
        if active_popup == widget then
            active_popup = nil
            stop_escape_listener()
            backdrop.hide()
        end
    end)
end

-- Menu-specific wrapper
local function click_to_hide_menu(menu, hide_fct, options)
    hide_fct = hide_fct or function()
        menu:hide()
    end
    -- Use the menu object directly since awful.popup doesn't have .wibox property
    click_to_hide(menu, hide_fct, options)
end

-- Utility functions for manual popup management
popup_manager.hide_all = hide_all_popups
popup_manager.get_active = function() return active_popup end
popup_manager.is_any_visible = function()
    for popup, _ in pairs(registered_popups) do
        if popup.visible then
            return true
        end
    end
    return false
end

-- Register a popup with custom behavior
popup_manager.register = function(widget, hide_function, options)
    click_to_hide(widget, hide_function, options)
end

-- Unregister a popup
popup_manager.unregister = function(widget)
    registered_popups[widget] = nil
    if active_popup == widget then
        active_popup = nil
        stop_escape_listener()
    end
end

return {
    menu = click_to_hide_menu,
    popup = click_to_hide,
    manager = popup_manager,
}
