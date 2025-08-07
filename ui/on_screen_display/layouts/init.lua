local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local dpi = beautiful.xresources.apply_dpi
local shapes = require('modules.shapes')

local osd = {}

local function new()
    local ll = awful.widget.layoutlist({
        spacing = dpi(32),
        base_layout = {
            spacing = dpi(72),
            forced_num_cols = 4,
            layout = wibox.layout.grid.vertical,
        },
        widget_template = {
            {
                {
                    id = "icon_role",
                    forced_height = dpi(96),
                    forced_width = dpi(96),
                    widget = wibox.widget.imagebox,
                },
                margins = dpi(16),
                widget = wibox.container.margin,
            },
            id = "background_role",
            forced_width = dpi(108),
            forced_height = dpi(108),
            widget = wibox.container.background,
        },
    })

    local ret = awful.popup({
        widget = {
            ll,
            margins = dpi(32),
            widget = wibox.container.margin,
        },
        border_width = dpi(2.25),
        placement = awful.placement.centered,
        ontop = true,
        visible = false,
    })

    gtable.crush(ret, osd, true)
    local wp = ret._private
    wp.ll = ll
    wp.theme_applied = false

    wp.timer = gtimer({
        timeout = 1.5,
        autostart = false,
        callback = function()
            ret:hide()
        end,
    })

    return ret
end

function osd:show()
    local wp = self._private
    self.screen = awful.screen.focused()
    wp.ll.screen = self.screen

    if not wp.theme_applied then
        for _, widget in ipairs(wp.ll.children) do
            widget.shape = shapes.rrect(5)
            widget.widget.shape = shapes.rrect(5)
            widget.widget.widget.shape = shapes.rrect(5)
        end

        self.border_color = beautiful.bg_normal .. "44"
        self.bg = beautiful.bg_normal .. "aa"
        self.shape = shapes.rrect_12
        wp.theme_applied = true
    end

    local current_layout = awful.layout.get(self.screen)
    local layouts = wp.ll:get_layouts()
    for i, layout in ipairs(layouts) do
        local widget = wp.ll.children[i]
        if widget then
            if layout == current_layout then
                widget.bg = beautiful.bg_alt
                widget.border_width = dpi(1)
                widget.border_color = beautiful.fg_alt .. "99"
            else
                widget.bg = beautiful.bg_normal .. "44"
                widget.border_width = 0
            end
        end
    end

    self.visible = true
    if wp.timer.started then
        wp.timer:again()
    else
        wp.timer:start()
    end
end

function osd:hide()
    self.visible = false
    local wp = self._private
    wp.timer:stop()
end

local instance = nil
function osd.get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return osd
