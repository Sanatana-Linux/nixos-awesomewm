-- Centralized popup management module
-- Handles click-to-hide on backdrop, escape key, and exclusive popup behavior

local awful = require("awful")
local backdrop = require("modules.backdrop")

local popup_manager = {}

-- Track all registered popups
local registered_popups = {}
local active_popup = nil
local escape_grabber = nil

local function hide_all_popups()
    for popup, data in pairs(registered_popups) do
        if data.hide_function then
            data.hide_function()
        end
    end
    active_popup = nil
end

local function stop_escape_listener()
    if escape_grabber then
        awful.keygrabber.stop(escape_grabber)
        escape_grabber = nil
    end
end

local function start_escape_listener()
    stop_escape_listener()
    escape_grabber = awful.keygrabber.run(function(_, key, event)
        if event == "press" and key == "Escape" then
            hide_all_popups()
            stop_escape_listener()
        end
    end)
end

-- Set up click-to-hide on the backdrop wibox
local function setup_backdrop_click(hide_fct)
    for s, bw in pairs(backdrop.get_wiboxes()) do
        if bw then
            bw.buttons = {
                awful.button({}, 1, hide_fct),
                awful.button({}, 2, hide_fct),
                awful.button({}, 3, hide_fct),
            }
        end
    end
end

local function clear_backdrop_click()
    for s, bw in pairs(backdrop.get_wiboxes()) do
        if bw then
            bw.buttons = {}
        end
    end
end

local function click_to_hide(widget, hide_fct, options)
    options = options or {}
    local exclusive = options.exclusive ~= false
    local disable_escape = options.disable_escape or false

    hide_fct = hide_fct or function()
        widget.visible = false
    end

    -- Register this popup
    registered_popups[widget] = {
        hide_function = hide_fct,
        exclusive = exclusive,
        disable_escape = disable_escape,
    }

    -- Handle visibility changes
    widget:connect_signal("property::visible", function(w)
        if not w.visible then
            -- Popup being hidden
            if active_popup == widget then
                active_popup = nil
                stop_escape_listener()
                clear_backdrop_click()
            end
        else
            -- Popup being shown
            if exclusive then
                for popup, data in pairs(registered_popups) do
                    if popup ~= widget and popup.visible and data.exclusive then
                        data.hide_function()
                    end
                end
            end

            active_popup = widget

            if not disable_escape then
                start_escape_listener()
            end

            setup_backdrop_click(hide_fct)
        end
    end)

    -- Clean up when widget is destroyed
    widget:connect_signal("widget::destroyed", function()
        registered_popups[widget] = nil
        if active_popup == widget then
            active_popup = nil
            stop_escape_listener()
        end
    end)
end

-- Popup variant
popup_manager.popup = click_to_hide

-- Menu variant
popup_manager.menu = function(menu, hide_fct, options)
    options = options or {}
    local exclusive = options.exclusive ~= false
    local disable_escape = options.disable_escape or false

    hide_fct = hide_fct or function()
        menu:hide()
    end

    registered_popups[menu] = {
        hide_function = hide_fct,
        exclusive = exclusive,
        disable_escape = disable_escape,
    }

    menu:connect_signal("property::visible", function(w)
        if not w.visible then
            if active_popup == menu then
                active_popup = nil
                stop_escape_listener()
                clear_backdrop_click()
            end
        else
            if exclusive then
                for popup, data in pairs(registered_popups) do
                    if popup ~= menu and popup.visible and data.exclusive then
                        data.hide_function()
                    end
                end
            end

            active_popup = menu

            if not disable_escape then
                start_escape_listener()
            end

            setup_backdrop_click(hide_fct)
        end
    end)
end

popup_manager.hide_all = hide_all_popups
popup_manager.get_active = function()
    return active_popup
end
popup_manager.is_any_visible = function()
    for popup, _ in pairs(registered_popups) do
        if popup.visible then
            return true
        end
    end
    return false
end
popup_manager.register = function(widget, hide_function, options)
    click_to_hide(widget, hide_function, options)
end
popup_manager.unregister = function(widget)
    registered_popups[widget] = nil
    if active_popup == widget then
        active_popup = nil
        stop_escape_listener()
    end
end

return popup_manager
