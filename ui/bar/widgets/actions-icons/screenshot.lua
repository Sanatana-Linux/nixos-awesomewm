---@diagnostic disable: undefined-global
--  _______                                     __           __
-- |     __|.----.----.-----.-----.-----.-----.|  |--.-----.|  |_
-- |__     ||  __|   _|  -__|  -__|     |__ --||     |  _  ||   _|
-- |_______||____|__| |_____|_____|__|__|_____||__|__|_____||____|

--  ______         __   __
-- |   __ \.--.--.|  |_|  |_.-----.-----.
-- |   __ <|  |  ||   _|   _|  _  |     |
-- |______/|_____||____|____|_____|__|__|
-- -------------------------------------------------------------------------- --
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")

require("ui.bar.widgets.actions-icons.widgets.screenshot-select")

local function get_icon(s)
    local CAMERA_ICON =
        gears.color.recolor_image(icons.camera, beautiful.fg_normal)

    local icon = wibox.widget({
        id = "screenshot_action_icon",
        image = CAMERA_ICON,
        align = "center",
        widget = wibox.widget.imagebox,
    })

    local tooltip = utilities.widgets.make_popup_tooltip(
        "Press to take a screenshot",
        function(d)
            return awful.placement.bottom_right(d, {
                margins = {
                    bottom = beautiful.bar_height
                        + beautiful.useless_gap * 1.25,
                    right = beautiful.useless_gap * 2 + 85,
                },
            })
        end
    )

    tooltip.attach_to_object(icon)

    icon:add_button(awful.button({}, 1, function()
        s.screenshot_selecter.toggle()
        tooltip.toggle()

        if s.screenshot_selecter.popup.visible then
            icon.image = gears.color.recolor_image(icons.camera, beautiful.grey)
            awesome.emit_signal("screenshot::show")
        else
            icon.image = CAMERA_ICON
            awesome.emit_signal("screenshot::hide")
        end
    end))

    awesome.connect_signal("screenshot::show", function()
        icon.image =
            gears.color.recolor_image(icons.camera, beautiful.bg_normal .. "66")
    end)

    awesome.connect_signal("screenshot::hide", function()
        icon.image = CAMERA_ICON
    end)

    return icon
end

return get_icon
