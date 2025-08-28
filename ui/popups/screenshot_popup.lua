local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local gobject = require("gears.object")
local gtable = require("gears.table")
local dpi = beautiful.xresources.apply_dpi
local shapes = require("modules.shapes")
local modules = require("modules")
local click_to_hide = require("modules.click_to_hide")
local screenshot_service = require("service.screenshot").get_default()

local function createButton(icon_path, name, fn)
    local button = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg_gradient_button,
        shape = shapes.rrect(8),
        forced_width = dpi(108),
        forced_height = dpi(108),
        buttons = {
            awful.button({}, 1, function()
                fn()
            end),
        },
        {
            widget = wibox.container.margin,
            margins = dpi(15),
            {
                widget = wibox.container.place,
                halign = "center",
                valign = "center",
                {
                    widget = wibox.widget.imagebox,
                    image = icon_path,
                    resize = true,
                    forced_width = dpi(48),
                    forced_height = dpi(48),
                },
            },
        },
    })

    -- Add hover effects manually
    button:connect_signal("mouse::enter", function(w)
        w:set_bg(beautiful.bg_gradient_button_alt)
    end)
    
    button:connect_signal("mouse::leave", function(w)
        w:set_bg(beautiful.bg_gradient_button)
    end)

    awful.tooltip({
        objects = { button },
        text = name,
        bg = beautiful.bg_urg,
        fg = beautiful.fg,
    })

    return button
end

local screenshot_popup = {}

function screenshot_popup:new()
    local ret = gobject({})
    gtable.crush(ret, screenshot_popup, true)

    ret.widget = wibox({
        width = dpi(450),
        height = dpi(220),
        shape = shapes.rrect(12),
        bg = beautiful.bg and (beautiful.bg .. "bb") or "#000000bb",
        border_width = dpi(1),
        border_color = beautiful.ac,
        ontop = true,
        visible = false,
        type = "popup_menu",
    })

    local close_popup = function()
        ret:hide()
    end

    local fullscreen_btn = createButton(beautiful.screenshot_icons.fullscreen, "Fullscreen", function()
        close_popup()
        screenshot_service:take_full()
    end)

    local selection_btn = createButton(beautiful.screenshot_icons.selection, "Selection", function()
        close_popup()
        screenshot_service:take_select()
    end)

    local delay_btn = createButton(beautiful.screenshot_icons.delay, "Delay 3s", function()
        close_popup()
        screenshot_service:take_delay(3)
    end)

    local close_button = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg_gradient_button,
        shape = shapes.rrect(8),
        forced_width = dpi(32),
        forced_height = dpi(32),
        buttons = {
            awful.button({}, 1, function()
                close_popup()
            end),
        },
        {
            widget = wibox.container.margin,
            margins = dpi(6),
            {
                widget = wibox.container.place,
                halign = "center",
                valign = "center",
                {
                    widget = wibox.widget.imagebox,
                    image = gears.color.recolor_image(beautiful.titlebar_icons.close, beautiful.fg),
                    resize = true,
                    forced_width = dpi(20),
                    forced_height = dpi(20),
                },
            },
        },
    })

    -- Add hover effects
    close_button:connect_signal("mouse::enter", function(w)
        w:set_bg("linear:0,0:0,32:0," .. beautiful.red .. ":1," .. "#b61442")
    end)
    
    close_button:connect_signal("mouse::leave", function(w)
        w:set_bg(beautiful.bg_gradient_button)
    end)

    ret.widget:setup({
        {
            {
                {
                    nil,
                    {
                        text = "Screenshot",
                        font = beautiful.font_name .. dpi(24),
                        align = "center",
                        valign = "center",
                        widget = wibox.widget.textbox,
                    },
                    close_button,
                    layout = wibox.layout.align.horizontal,
                },
                margins = dpi(12),
                widget = wibox.container.margin,
            },
            {
                {
                    fullscreen_btn,
                    selection_btn,
                    delay_btn,
                    spacing = dpi(30),
                    layout = wibox.layout.fixed.horizontal,
                },
                halign = "center",
                widget = wibox.container.place,
            },
            spacing = dpi(8),
            layout = wibox.layout.fixed.vertical,
        },
        margins = dpi(2),
        widget = wibox.container.margin,
    })

    function ret:show()
        self.widget.visible = true
        awful.placement.centered(self.widget)
        self:emit_signal("property::shown", true)
    end

    function ret:hide()
        self.widget.visible = false
        self:emit_signal("property::shown", false)
    end

    function ret:toggle()
        if self.widget.visible then
            self:hide()
        else
            self:show()
        end
    end

    -- Setup click-to-hide behavior
    click_to_hide.popup(ret.widget, function()
        ret:hide()
    end, { outside_only = true, exclusive = true })

    return ret
end

local instance = nil
local function get_default()
    if not instance then
        instance = screenshot_popup:new()
    end
    return instance
end

return {
    get_default = get_default,
}
