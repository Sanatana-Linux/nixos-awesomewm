local awful = require("awful")
local beautiful = require("beautiful")

local popup_manager = {}

local registered_popups = {}
local active_popup = nil
local escape_grabber = nil

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
            if active_popup and registered_popups[active_popup] then
                registered_popups[active_popup].hide_function()
            end
            stop_escape_listener()
        end
    end)
end

local function hide_all_popups()
    for popup, data in pairs(registered_popups) do
        if data.hide_function then
            data.hide_function()
        end
    end
    active_popup = nil
    stop_escape_listener()
end

local function activate_popup(widget)
    if active_popup == widget then
        return
    end

    for popup, data in pairs(registered_popups) do
        if popup ~= widget and popup.visible and data.exclusive then
            data.hide_function()
        end
    end

    active_popup = widget
    start_escape_listener()
end

local function deactivate_popup(widget)
    if active_popup == widget then
        active_popup = nil
        stop_escape_listener()
    end
end

local function click_to_hide(widget, hide_fct, options)
    options = options or {}
    local exclusive = options.exclusive ~= false
    local enable_escape = options.enable_escape ~= false
    local popup_name = options.popup_name or "awesome-popup"

    hide_fct = hide_fct or function()
        widget.visible = false
    end

    registered_popups[widget] = {
        hide_function = hide_fct,
        exclusive = exclusive,
        enable_escape = enable_escape,
    }

    if widget.set_name then
        widget:set_name(popup_name)
    elseif widget.name then
        widget.name = popup_name
    end

    widget:connect_signal("property::visible", function(w)
        if not w.visible then
            deactivate_popup(widget)
        else
            if exclusive then
                for popup, data in pairs(registered_popups) do
                    if popup ~= widget and popup.visible and data.exclusive then
                        data.hide_function()
                    end
                end
            end
            activate_popup(widget)
        end
    end)

    widget:connect_signal("widget::destroyed", function()
        registered_popups[widget] = nil
        deactivate_popup(widget)
    end)
end

popup_manager.popup = click_to_hide

popup_manager.menu = function(menu_obj, hide_fct, options)
    options = options or {}
    local exclusive = options.exclusive ~= false

    hide_fct = hide_fct or function()
        menu_obj:hide()
    end

    registered_popups[menu_obj] = {
        hide_function = hide_fct,
        exclusive = exclusive,
        enable_escape = true,
    }

    menu_obj:connect_signal("property::visible", function(w)
        if not w.visible then
            deactivate_popup(menu_obj)
        else
            if exclusive then
                for popup, data in pairs(registered_popups) do
                    if popup ~= menu_obj and popup.visible and data.exclusive then
                        data.hide_function()
                    end
                end
            end
            activate_popup(menu_obj)
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
popup_manager.register = click_to_hide
popup_manager.unregister = function(widget)
    registered_popups[widget] = nil
    deactivate_popup(widget)
end

return popup_manager