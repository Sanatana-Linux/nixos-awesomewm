--- Click-to-dismiss popup coordinator.
-- Singleton that tracks registered popups and provides:
--   * `popup_manager.popup(widget, hide_fct, opts?)` — register a popup
--   * `popup_manager.menu(menu, hide_fct, opts?)` — register a menu
--   * `popup_manager.hide_all()` — hide every registered popup
--   * `popup_manager.get_active()` — current active popup (or nil)
--   * `popup_manager.is_any_visible()` — any visible?
--   * `popup_manager.unregister(widget)` — remove a popup
--
-- When a registered popup emits `property::visible = true`, any other
-- `exclusive` (default) popup is hidden via its `hide_function`. When the
-- popup hides, the active-popup state is cleared. An optional escape
-- keygrabber is started when the popup is shown (also default-on).
-- @module modules.click_to_hide

local awful = require("awful")
local beautiful = require("beautiful")

local popup_manager = {}

local registered_popups = {}
local active_popup = nil
local escape_grabber = nil

--- Stop the Escape keygrabber, if active.
-- @local
local function stop_escape_listener()
    if escape_grabber then
        awful.keygrabber.stop(escape_grabber)
        escape_grabber = nil
    end
end

--- Start an Escape keygrabber for the active popup.
-- Pressing Escape calls the active popup's hide function.
-- @local
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

--- Hide all registered popups and clear active-popup state.
-- @local
local function hide_all_popups()
    for popup, data in pairs(registered_popups) do
        if data.hide_function then
            data.hide_function()
        end
    end
    active_popup = nil
    stop_escape_listener()
end

--- Mark a popup as active, hiding any other exclusive popup first.
-- Starts the Escape listener if the popup has `enable_escape`.
-- @tparam widget widget The popup becoming active
-- @local
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
    local popup_data = registered_popups[widget]
    if popup_data and popup_data.enable_escape then
        start_escape_listener()
    end
end

--- Clear the active-popup state and stop the Escape listener.
-- @tparam widget widget The popup being deactivated
-- @local
local function deactivate_popup(widget)
    if active_popup == widget then
        active_popup = nil
        stop_escape_listener()
    end
end

--- Register a popup for click-to-dismiss + mutual-exclusion tracking.
-- @tparam widget widget The popup widget
-- @tparam[opt] function hide_fct Called when another popup activates
--   and asks this one to hide (default: sets `widget.visible = false`)
-- @tparam[opt] table opts
-- @tparam[opt=true] boolean opts.exclusive If true, hiding this popup
--   triggers hide on other exclusive popups when it activates
-- @tparam[opt=true] boolean opts.enable_escape If true, an Escape keygrabber
--   is started when the popup activates
-- @tparam[opt="awesome-popup"] string opts.popup_name Set as `widget.name`
--   so the wm can identify it
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

--- Register a menu (like `popup` but always has `enable_escape = true`).
-- @tparam menu menu_obj The menu widget
-- @tparam[opt] function hide_fct Called when another menu asks this one
--   to hide (default: `menu_obj:hide()`)
-- @tparam[opt] table opts `@see click_to_hide` (the `enable_escape` flag is
--   forced to true here and can't be turned off)
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
                    if
                        popup ~= menu_obj
                        and popup.visible
                        and data.exclusive
                    then
                        data.hide_function()
                    end
                end
            end
            activate_popup(menu_obj)
        end
    end)
end

popup_manager.hide_all = hide_all_popups

--- Return the currently-active popup or nil.
-- @treturn widget|nil
popup_manager.get_active = function()
    return active_popup
end

--- Check whether any registered popup is currently visible.
-- @treturn boolean
popup_manager.is_any_visible = function()
    for popup, _ in pairs(registered_popups) do
        if popup.visible then
            return true
        end
    end
    return false
end
popup_manager.register = click_to_hide

--- Remove a popup from the coordinator (no signal is fired).
-- @tparam widget widget
popup_manager.unregister = function(widget)
    registered_popups[widget] = nil
    deactivate_popup(widget)
end

return popup_manager
