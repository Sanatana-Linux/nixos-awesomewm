---@diagnostic disable: undefined-global
--[[
Window Switcher — Alt+Tab popup showing client icons as horizontal buttons.

Design:
  - Horizontal row of client icon buttons (no titles), matching wibar button styling
  - Same transparent rounded background as control_panel
  - Currently-focused client gets a highlighted border (selected state)
  - Activated by system keybind via window_switcher::turn_on / turn_off signals
  - Focus cycling handled externally by the keygrabber in system.lua
  - Singleton pattern (get_default()) per project convention
--]]

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local gtable = require("gears.table")
local shapes = require("modules.shapes")
local icon_lookup = require("modules.icon-lookup")
local styled_button = require("modules.styled_button")
local dpi = beautiful.xresources.apply_dpi
local capi = { client = client, awesome = awesome }

local window_switcher = { _private = {} }

-- --------------------------------------------------------------------------
-- Create a client icon button with selectable state
-- Uses styled_button.create() (not create_icon_button) for set_selected support
-- --------------------------------------------------------------------------
local function make_client_button(c)
    local icon_path = icon_lookup.get_client_icon(c)
    local icon_size = dpi(32)

    local icon_widget = wibox.widget({
        widget = wibox.widget.imagebox,
        image = icon_path,
        resize = true,
        forced_width = icon_size,
        forced_height = icon_size,
    })

    -- Determine if this client is currently focused
    local is_focused = c == capi.client.focus

    local btn = styled_button.create({
        content = icon_widget,
        width = icon_size,
        height = icon_size,
        margin_top = dpi(6),
        margin_bottom = dpi(6),
        margin_left = dpi(10),
        margin_right = dpi(10),
        shape = shapes.rrect(dpi(10)),
        selected = is_focused,
        buttons = {
            awful.button({}, 1, function()
                c:jump_to()
            end),
        },
    })

    return btn
end

-- --------------------------------------------------------------------------
-- Build the popup widget
-- --------------------------------------------------------------------------
local function build_popup()
    local tag = awful.screen.focused().selected_tag
    if not tag then
        return wibox.widget({ widget = wibox.widget.base.make_widget })
    end

    local clients = tag:clients()
    if #clients == 0 then
        return wibox.widget({ widget = wibox.widget.base.make_widget })
    end

    -- Build horizontal layout of icon buttons with generous spacing
    local icon_layout = wibox.layout.fixed.horizontal()
    icon_layout.spacing = dpi(16)

    for _, c in ipairs(clients) do
        if c.valid then
            icon_layout:add(make_client_button(c))
        end
    end

    -- Wrap in the same transparent box as control_panel
    return wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg .. "55",
        border_width = beautiful.border_width,
        border_color = beautiful.border_color_normal,
        shape = shapes.rrect(20),
        {
            widget = wibox.container.margin,
            margins = dpi(16),
            {
                widget = wibox.container.place,
                valign = "center",
                halign = "center",
                icon_layout,
            },
        },
    })
end

-- --------------------------------------------------------------------------
-- Rebuild the icon list (called after focus cycles)
-- --------------------------------------------------------------------------
local function rebuild(wp)
    if not wp.popup or not wp.popup.visible then
        return
    end
    wp.popup.widget = build_popup()
end

-- --------------------------------------------------------------------------
-- Show / hide
-- --------------------------------------------------------------------------
function window_switcher:show()
    local wp = self._private
    if wp.popup then
        wp.popup.visible = true
        wp.popup.screen = awful.screen.focused()
        rebuild(wp)
        return
    end

    local popup = awful.popup({
        bg = "#00000000",
        visible = true,
        ontop = true,
        placement = awful.placement.centered,
        screen = awful.screen.focused(),
        widget = build_popup(),
    })

    -- Auto-hide if no clients remain
    popup:connect_signal("property::width", function()
        if popup.visible then
            local tag = awful.screen.focused().selected_tag
            if tag and #tag:clients() == 0 then
                self:hide()
            end
        end
    end)

    wp.popup = popup
end

function window_switcher:hide()
    local wp = self._private
    if wp.popup then
        wp.popup.visible = false
        wp.popup.widget = nil
        wp.popup = nil
        collectgarbage("collect")
    end
end

-- --------------------------------------------------------------------------
-- Signal wiring
-- --------------------------------------------------------------------------
capi.awesome.connect_signal("window_switcher::turn_on", function()
    local tag = awful.screen.focused().selected_tag
    if not tag or #tag:clients() == 0 then
        return
    end

    local wp = window_switcher._private

    -- Temporarily unminimize clients so they appear in the list
    wp.minimized_clients = {}
    for _, c in ipairs(tag:clients()) do
        if c.minimized then
            table.insert(wp.minimized_clients, c)
            c.minimized = false
            c:lower()
        end
    end

    window_switcher:show()
end)

capi.awesome.connect_signal("window_switcher::turn_off", function()
    local wp = window_switcher._private

    -- Re-minimize clients that were minimized before
    if wp.minimized_clients then
        for _, c in ipairs(wp.minimized_clients) do
            if c and c.valid then
                c.minimized = true
            end
        end
        wp.minimized_clients = nil
    end

    window_switcher:hide()
end)

-- Rebuild the icon list whenever focus changes while the switcher is visible
-- This keeps the "selected" visual state in sync with the actual focus
capi.client.connect_signal("focus", function()
    local wp = window_switcher._private
    if wp.popup and wp.popup.visible then
        rebuild(wp)
    end
end)

-- Also rebuild when a client is un/managed (window opened/closed during switcher)
capi.client.connect_signal("managed", function()
    local wp = window_switcher._private
    if wp.popup and wp.popup.visible then
        rebuild(wp)
    end
end)

capi.client.connect_signal("unmanaged", function()
    local wp = window_switcher._private
    if wp.popup and wp.popup.visible then
        rebuild(wp)
    end
end)

-- --------------------------------------------------------------------------
-- Singleton
-- --------------------------------------------------------------------------
local instance

local function new()
    local ret = {}
    gtable.crush(ret, window_switcher, true)
    return ret
end

local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return {
    get_default = get_default,
}
