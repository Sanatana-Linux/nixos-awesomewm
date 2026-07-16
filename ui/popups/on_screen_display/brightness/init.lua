--- Brightness OSD popup.
-- Shows a short-lived progress bar overlay at the bottom of the
-- screen with a brightness icon + percentage label. Auto-hides
-- after 4 seconds.
-- @module ui.popups.on_screen_display.brightness

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local animation = require("modules.infra.animations")
local dpi = beautiful.xresources.apply_dpi

local osd = {}

--- Construct and return a new brightness OSD popup (singleton).
-- @treturn table OSD instance with show/hide/get_default methods
local function new()
    local ret = awful.popup({
        visible = false,
        ontop = true,
        minimum_height = dpi(60),
        maximum_height = dpi(60),
        minimum_width = dpi(290),
        maximum_width = dpi(290),
        placement = function(d)
            awful.placement.bottom(
                d,
                { margins = { bottom = dpi(20) }, honor_workarea = true }
            )
        end,
        widget = {
            widget = wibox.container.margin,
            margins = dpi(20),
            {
                layout = wibox.layout.fixed.horizontal,
                fill_space = true,
                spacing = dpi(8),
                {
                    widget = wibox.widget.textbox,
                    id = "icon",
                    font = beautiful.font_name .. " 14",
                },
                {
                    widget = wibox.container.background,
                    forced_width = dpi(36),
                    {
                        widget = wibox.widget.textbox,
                        id = "text",
                        halign = "center",
                    },
                },
                {
                    widget = wibox.widget.progressbar,
                    id = "progressbar",
                    max_value = 100,
                    forced_width = dpi(380),
                    forced_height = dpi(10),
                    background_color = beautiful.bg_normal,
                    color = beautiful.fg,
                },
            },
        },
    })

    gtable.crush(ret, osd, true)
    local wp = ret._private

    wp.timer = gtimer({
        timeout = 4,
        autostart = false,
        callback = function()
            ret:hide()
        end,
    })

    return ret
end

--- Show the brightness OSD with animated progress bar.
-- Selects the icon glyph based on the value range.
-- Resets the auto-hide timer on every call.
-- @tparam integer value Brightness percentage (0–100)
function osd:show(value)
    local wp = self._private
    local icon_widget = self.widget:get_children_by_id("icon")[1]
    local text_widget = self.widget:get_children_by_id("text")[1]
    local progressbar_widget = self.widget:get_children_by_id("progressbar")[1]

    if value > 90 then
        icon_widget.text = "󰃠"
    elseif value > 60 then
        icon_widget.text = "󰃟"
    elseif value > 30 then
        icon_widget.text = "󰃝"
    elseif value > 10 then
        icon_widget.text = "󰃞"
    end

    text_widget.text = tostring(value)

    animation.animate({
        start = progressbar_widget.value,
        target = value,
        duration = 0.3,
        easing = animation.easing.linear,
        update = function(progress)
            progressbar_widget.value = progress
        end,
    })

    if not self.visible then
        self.visible = true
        wp.timer:start()
    else
        wp.timer:again()
    end
end

--- Hide the brightness OSD immediately.
function osd:hide()
    self.visible = false
    local wp = self._private
    wp.timer:stop()
end

local instance = nil
--- Singleton accessor: returns (and lazily constructs) the brightness OSD.
-- @treturn table Cached OSD instance
function osd.get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return osd
