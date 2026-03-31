--[[
Bluetooth Applet Button Widget

Creates a toggle button for the control panel that allows users to:
- Enable/disable Bluetooth adapter with a single click
- Reveal the full Bluetooth management page via the arrow button
--]]

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gcolor = require("gears.color")
local gfs = require("gears.filesystem")
local shapes = require("modules.shapes.init")
local dpi = beautiful.xresources.apply_dpi
local applet_buttons = require("modules.applet_buttons")

local adapter = require("service.bluetooth").get_default()

------------------------------------------------------------------------
-- Configuration
------------------------------------------------------------------------

local ICONS_DIR = gfs.get_configuration_dir()
    .. "ui/popups/control_panel/bluetooth_applet/icons/"
local BLUETOOTH_ICON = ICONS_DIR .. "bluetooth.svg"
local ARROW_ICON = ICONS_DIR .. "arrow-right.svg"

------------------------------------------------------------------------
-- Widget Factory
------------------------------------------------------------------------

local function new()
    local ret = applet_buttons.create_base_button({
        bg = beautiful.bg_alt,
        toggle_area = {
            id = "toggle-button",
            widget = wibox.container.background,
            forced_width = applet_buttons.TOGGLE_AREA_WIDTH,
            {
                widget = wibox.container.margin,
                margins = { left = dpi(15) },
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(15),
                    {
                        widget = wibox.container.place,
                        halign = "center",
                        valign = "center",
                        {
                            id = "toggle-icon",
                            widget = wibox.widget.imagebox,
                            image = gcolor.recolor_image(BLUETOOTH_ICON, applet_buttons.WHITE),
                            forced_height = dpi(18),
                            forced_width = dpi(18),
                            resize = true,
                        },
                    },
                    {
                        widget = wibox.container.place,
                        halign = "center",
                        {
                            layout = wibox.layout.fixed.vertical,
                            {
                                widget = wibox.widget.textbox,
                                markup = "<span foreground='"
                                    .. applet_buttons.WHITE
                                    .. "'><b>Bluetooth</b></span>",
                            },
                            {
                                id = "state-label",
                                widget = wibox.widget.textbox,
                                font = beautiful.font_name .. dpi(9),
                            },
                        },
                    },
                },
            },
        },
        reveal_area = {
            id = "reveal-button",
            widget = wibox.container.background,
            forced_width = applet_buttons.REVEAL_AREA_WIDTH,
            {
                widget = wibox.container.place,
                halign = "center",
                valign = "center",
                {
                    widget = wibox.container.margin,
                    margins = dpi(6),
                    {
                        id = "reveal-icon",
                        widget = wibox.widget.imagebox,
                        image = gcolor.recolor_image(ARROW_ICON, applet_buttons.WHITE),
                        forced_height = dpi(18),
                        forced_width = dpi(18),
                        resize = true,
                    },
                },
            },
        },
    })

    -- References
    local wp = ret._private
    local toggle_button = ret:get_children_by_id("toggle-button")[1]
    local toggle_icon = ret:get_children_by_id("toggle-icon")[1]
    local reveal_button = ret:get_children_by_id("reveal-button")[1]
    local reveal_icon = ret:get_children_by_id("reveal-icon")[1]
    local separator = ret:get_children_by_id("separator")[1]
    local state_label = ret:get_children_by_id("state-label")[1]

    --------------------------------------------------------------------
    -- State Update Functions
    --------------------------------------------------------------------

    wp.on_powered = function(_, powered)
        if powered then
            state_label:set_markup(
                "<span foreground='" .. applet_buttons.WHITE .. "'>Enabled</span>"
            )
            ret:set_bg(beautiful.ac)
            ret:set_fg(applet_buttons.WHITE)
            ret:set_border_color(applet_buttons.WHITE)
            toggle_button:set_bg(beautiful.ac)
            toggle_icon:set_image(gcolor.recolor_image(BLUETOOTH_ICON, applet_buttons.WHITE))
            reveal_icon:set_image(gcolor.recolor_image(ARROW_ICON, applet_buttons.WHITE))
            separator:set_color(applet_buttons.WHITE)
        else
            state_label:set_markup(
                "<span foreground='" .. applet_buttons.WHITE .. "'>Disabled</span>"
            )
            ret:set_bg(beautiful.bg_alt)
            ret:set_fg(applet_buttons.WHITE)
            ret:set_border_color(applet_buttons.WHITE)
            toggle_button:set_bg(nil)
            toggle_icon:set_image(gcolor.recolor_image(BLUETOOTH_ICON, applet_buttons.WHITE))
            reveal_icon:set_image(gcolor.recolor_image(ARROW_ICON, applet_buttons.WHITE))
            separator:set_color(applet_buttons.WHITE)
        end
    end

    --------------------------------------------------------------------
    -- Logic
    --------------------------------------------------------------------

    wp.on_hovered = function(_, is_hovered)
        if adapter:get_powered() then return end
        if is_hovered then
            toggle_button:set_bg(beautiful.bg)
            separator:set_color(beautiful.fg_alt)
        else
            toggle_button:set_bg(nil)
            separator:set_color(applet_buttons.WHITE)
        end
    end

    wp.on_pressed = function(_, is_pressed)
        if adapter:get_powered() then return end
        if is_pressed then
            toggle_button:set_bg(nil)
            separator:set_color(applet_buttons.WHITE)
        else
            toggle_button:set_bg(beautiful.bg)
            separator:set_color(beautiful.fg_alt)
        end
    end

    adapter:connect_signal("property::powered", wp.on_powered)

    toggle_button:connect_signal("mouse::enter", function() wp.on_hovered(nil, true) end)
    toggle_button:connect_signal("mouse::leave", function() wp.on_hovered(nil, false) end)
    toggle_button:connect_signal("button::press", function() wp.on_pressed(nil, true) end)
    toggle_button:connect_signal("button::release", function() wp.on_pressed(nil, false) end)

    toggle_button:buttons({
        awful.button({}, 1, function()
            adapter:set_powered(not adapter:get_powered())
        end),
    })

    reveal_button:connect_signal("mouse::enter", function()
        if not adapter:get_powered() then
            reveal_button:set_bg(beautiful.bg_urg)
            reveal_icon:set_image(gcolor.recolor_image(ARROW_ICON, applet_buttons.WHITE))
        end
    end)
    reveal_button:connect_signal("mouse::leave", function()
        if not adapter:get_powered() then
            reveal_button:set_bg(nil)
        end
    end)

    wp.on_powered(nil, adapter:get_powered())

    return ret
end

return setmetatable({ new = new }, { __call = new })
