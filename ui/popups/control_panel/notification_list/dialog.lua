--- Clear-all confirmation dialog.
-- Self-contained dialog with backdrop for confirming notification deletion.
-- Created via `create_confirmation_dialog(callback)` which returns `{show, hide}`.
-- @module ui.popups.control_panel.notification_list.dialog

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gcolor = require("gears.color")
local dpi = beautiful.xresources.apply_dpi
local create_markup = require("lib.util").create_markup
local shapes = require("modules.style.shapes")

local gfs = require("gears.filesystem")
local icons_dir = gfs.get_configuration_dir()
    .. "ui/popups/control_panel/notification_list/icons/"
local trash_icon = icons_dir .. "trash.svg"
local exit_icon = icons_dir .. "close.svg"

local FONT_NAME = beautiful.font_name or "Sans "

local dialog = {}

--- Create a confirmation dialog for clearing all notifications.
-- Shows a backdrop + centered dialog with Confirm/Cancel buttons.
-- The callback is invoked only on Confirm.
-- @tparam function callback Called when the user confirms clearing
-- @treturn table `{ show = function(), hide = function() }`
function dialog.create_confirmation_dialog(callback)
    local screen = awful.screen.focused()

    local backdrop = wibox({
        visible = false,
        ontop = false,
        type = "desktop",
        bg = "#00000033",
        x = screen.geometry.x,
        y = screen.geometry.y,
        width = screen.geometry.width,
        height = screen.geometry.height,
    })

    -- Table to hold the dialog widget for hide_dialog
    local dialog_functions = {}

    --- Hide the confirmation dialog.
    -- @local
    local function hide_dialog()
        backdrop.visible = false
        if dialog_functions.dialog then
            dialog_functions.dialog.visible = false
        end
    end

    --- Handle cancel button — just hide the dialog.
    -- @local
    local function handle_cancel()
        hide_dialog()
    end

    --- Handle clear all button — remove all notifications and hide dialog.
    -- @local
    local function handle_clear_all()
        hide_dialog()
        if callback then
            callback()
        else
            print("ERROR: No callback function provided")
        end
    end

    -- Create confirm button (left side)
    local confirm_icon = gcolor.recolor_image(trash_icon, beautiful.red)
    local confirm_icon_hover = gcolor.recolor_image(trash_icon, "#000000")
    local confirm_button = wibox.widget({
        widget = wibox.container.background,
        bg = "transparent",
        border_width = dpi(1),
        border_color = beautiful.red,
        shape = shapes.rrect(8),
        buttons = {
            awful.button({}, 1, handle_clear_all),
        },
        {
            widget = wibox.container.margin,
            margins = {
                left = dpi(28),
                right = dpi(8),
                top = dpi(12),
                bottom = dpi(12),
            },
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(3),
                {
                    id = "confirm-icon",
                    widget = wibox.widget.imagebox,
                    image = confirm_icon,
                    resize = true,
                    forced_width = dpi(24),
                    forced_height = dpi(24),
                },
                {
                    id = "confirm-label",
                    widget = wibox.widget.textbox,
                    align = "center",
                    markup = create_markup("Confirm", { fg = beautiful.red }),
                    font = FONT_NAME .. " " .. dpi(12),
                },
            },
        },
    })
    confirm_button:connect_signal("mouse::enter", function(w)
        w.bg = "linear:0,0:0,32:0,#fc618dcc:1,#b61442cc"
        w.border_color = "transparent"
        local icon = w:get_children_by_id("confirm-icon")[1]
        if icon then
            icon.image = confirm_icon_hover
        end
        local label = w:get_children_by_id("confirm-label")[1]
        if label then
            label:set_markup(create_markup("Confirm", { fg = "#000000" }))
        end
    end)
    confirm_button:connect_signal("mouse::leave", function(w)
        w.bg = "transparent"
        w.border_color = beautiful.red
        local icon = w:get_children_by_id("confirm-icon")[1]
        if icon then
            icon.image = confirm_icon
        end
        local label = w:get_children_by_id("confirm-label")[1]
        if label then
            label:set_markup(create_markup("Confirm", { fg = beautiful.red }))
        end
    end)

    -- Create cancel button (right side)
    local cancel_icon = gcolor.recolor_image(exit_icon, beautiful.fg)
    local cancel_button = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg_alt,
        border_width = dpi(2),
        border_color = beautiful.fg .. "66",
        shape = shapes.rrect(8),
        buttons = {
            awful.button({}, 1, handle_cancel),
        },
        {
            widget = wibox.container.margin,
            margins = {
                left = dpi(36),
                right = dpi(16),
                top = dpi(12),
                bottom = dpi(12),
            },
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(3),
                {
                    widget = wibox.widget.imagebox,
                    image = cancel_icon,
                    resize = true,
                    forced_width = dpi(24),
                    forced_height = dpi(24),
                },
                {
                    widget = wibox.widget.textbox,
                    align = "center",
                    markup = "Cancel",
                    font = FONT_NAME .. " " .. dpi(12),
                },
            },
        },
    })
    cancel_button:connect_signal("mouse::enter", function(w)
        w.bg = beautiful.bg_urg
    end)
    cancel_button:connect_signal("mouse::leave", function(w)
        w.bg = beautiful.bg_alt
    end)

    local dialog = awful.popup({
        visible = false,
        ontop = true,
        type = "dialog",
        screen = screen,
        bg = "#00000000",
        placement = awful.placement.centered,
        widget = {
            widget = wibox.container.background,
            bg = beautiful.bg .. "33",
            border_width = dpi(2),
            border_color = beautiful.fg_alt,
            shape = shapes.rrect(15),
            {
                widget = wibox.container.margin,
                margins = dpi(10),
                {
                    layout = wibox.layout.fixed.vertical,
                    spacing = dpi(32),
                    -- Title
                    {
                        widget = wibox.widget.textbox,
                        align = "center",
                        markup = create_markup("Clear All Notifications"),
                        font = FONT_NAME .. " 16",
                    },
                    -- Message
                    {
                        widget = wibox.widget.textbox,
                        align = "center",
                        markup = create_markup(
                            "This will permanently delete all"
                                .. " notification history.\n"
                                .. "Are you sure you want to continue?"
                        ),
                        font = FONT_NAME .. " 10",
                    },
                    -- Buttons
                    {
                        layout = wibox.layout.flex.horizontal,
                        spacing = dpi(12),
                        confirm_button,
                        cancel_button,
                    },
                },
            },
        },
    })

    dialog_functions.dialog = dialog

    -- Hide dialog when clicking backdrop
    backdrop.buttons = {
        awful.button({}, 1, hide_dialog),
    }

    return {
        show = function()
            backdrop.visible = true
            dialog.visible = true
        end,
        hide = hide_dialog,
    }
end

return dialog
