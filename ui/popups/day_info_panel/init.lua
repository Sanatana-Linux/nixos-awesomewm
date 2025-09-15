local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local modules = require("modules")
local dpi = beautiful.xresources.apply_dpi
local anim = require("modules.animations")
local capi = { screen = screen }
local click_to_hide = require("modules.click_to_hide")

local shapes = require("modules.shapes")
local rrect = shapes.rrect

local day_info = {}

function day_info:show()
    local wp = self._private
    if wp.shown then
        return
    end
    wp.shown = true

    if wp.calendar_widget and wp.calendar_widget.set_current_date then
        wp.calendar_widget:set_current_date()
    end

    self.opacity = 0
    self.visible = true
    self:emit_signal("widget::layout_changed")

    local final_y = self.y
    local start_y = final_y + dpi(20)
    self.y = start_y

    anim.animate({
        start = 0,
        target = 1,
        duration = 0.3,
        easing = anim.easing.quadratic,
        update = function(progress)
            self.opacity = progress
            self.y = start_y + (final_y - start_y) * progress
        end,
        complete = function()
            self:emit_signal("property::shown", wp.shown)
        end,
    })
end

function day_info:hide()
    local wp = self._private
    if not wp.shown then
        return
    end
    wp.shown = false

    local start_y = self.y
    local final_y = start_y + dpi(20)

    anim.animate({
        start = 1,
        target = 0,
        duration = 0.3,
        easing = anim.easing.quadratic,
        update = function(progress)
            self.opacity = progress
            self.y = final_y - (final_y - start_y) * progress
        end,
        complete = function()
            self.visible = false
            self:emit_signal("property::shown", wp.shown)
        end,
    })
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
        shape = shapes.rrect(10),
        day_shape = shapes.rrect_8,
    })

    local ret = awful.popup({
        visible = false,
        ontop = true,
        screen = capi.screen.primary or capi.screen[1],
        bg = "#00000000",
        placement = function(c)
            awful.placement.bottom_right(c, {
                honor_workarea = true,
                margins = {
                    bottom = beautiful.useless_gap * 2 + dpi(30),
                },
            })
        end,
        hide_on_unfocus = true,

        widget = {
            widget = wibox.container.background,
            bg = beautiful.bg,
            border_width = beautiful.border_width,
            border_color = beautiful.border_color_normal,
            shape = shapes.rrect_20,
            {
                widget = wibox.container.margin,
                margins = dpi(12),
                calendar_widget,
            },
        },
    })

    gtable.crush(ret, day_info, true)
    local wp = ret._private
    wp.calendar_widget = calendar_widget
    wp.shown = false

    -- Setup centralized click-to-hide behavior
    click_to_hide.popup(ret, function()
        ret:hide()
    end, { outside_only = true, exclusive = true })

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
