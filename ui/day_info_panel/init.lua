-- ui/day_info_panel/init.lua
-- This module defines the calendar popup (day info panel).
-- It is toggled by the time widget and includes refined placement logic.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local modules = require("modules")
local dpi = beautiful.xresources.apply_dpi
local capi = { screen = screen }

local rrect = beautiful.rrect or function(radius)
    return nil
end

local day_info = {}

function day_info:show()
    local wp = self._private
    if wp.shown then
        return
    end
    wp.shown = true

    -- Ensure the calendar is showing the current date when opened
    if wp.calendar_widget and wp.calendar_widget.set_current_date then
        wp.calendar_widget:set_current_date()
    end

    -- Explicitly set position to bottom right
    local s = self.screen
    local screen_geometry = s.geometry
    local margin_bottom = dpi(60) -- Adjust margin to clear the bar

    -- Calculate x and y for bottom-right placement
    -- We need the popup's width and height to calculate its top-left corner
    -- For now, let's assume a fixed size or let wibox calculate it and then adjust
    -- A better approach is to use awful.placement.bottom_right with honor_workarea = false
    -- but since that's not working, we'll try manual calculation.

    -- First, make it visible briefly to get its dimensions, then hide and reposition
    self.visible = true
    local popup_width = self.width
    local popup_height = self.height
    self.visible = false -- Hide it again

    self.x = screen_geometry.x + screen_geometry.width - popup_width
    self.y = screen_geometry.y + screen_geometry.height - popup_height - margin_bottom

    

    self.visible = true
    self:emit_signal("property::shown", wp.shown)
end

function day_info:hide()
    local wp = self._private
    if not wp.shown then
        return
    end
    wp.shown = false
    self.visible = false
    self:emit_signal("property::shown", wp.shown)
end

function day_info:toggle()
    if self.visible then
        self:hide()
    else
        self:show()
    end
end

local function new()
    local calendar_widget = modules.calendar({
        sun_start = false,
        shape = rrect(dpi(10)),
        day_shape = rrect(dpi(8)),
    })

    local ret = awful.popup({
        visible = false,
        ontop = true,
        screen = capi.screen.primary or capi.screen[1],
        bg = "#00000000",
        placement = awful.placement.bottom_right,

        widget = {
            widget = wibox.container.background,
            bg = beautiful.bg,
            border_width = beautiful.border_width,
            border_color = beautiful.border_color_normal,
            shape = rrect(dpi(20)),
            {
                widget = wibox.container.margin,
                margins = dpi(12),
                calendar_widget,
            },
        },
    })

    gtable.crush(ret, day_info, true)
    ret._private = {
        calendar_widget = calendar_widget,
        shown = false,
    }
    return ret
end

local instance = nil
local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return {
    get_default = get_default,
}
