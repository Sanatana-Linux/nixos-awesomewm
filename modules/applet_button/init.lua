local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gcolor = require("gears.color")
local shapes = require("modules.shapes")
local dpi = beautiful.xresources.apply_dpi

local function new(opts)
    opts = opts or {}
    local icon = opts.icon
    local description = opts.description or "Module"
    local handler = opts.handler
    local power_handler = opts.power_handler
    local adapter = opts.adapter
    local powered_signal = opts.powered_signal
    local arrow_icon = opts.arrow_icon
    local active_text = opts.active_text
    local inactive_text = opts.inactive_text

    local forced_width = dpi(225)
    local forced_height = dpi(60)

    local ret = wibox.widget({
        widget = wibox.container.background,
        forced_width = forced_width,
        forced_height = forced_height,
        bg = beautiful.bg_alt,
        fg = beautiful.fg,
        shape = shapes.rrect(10),
        border_width = dpi(1),
        border_color = beautiful.border_color,
        {
            widget = wibox.container.margin,
            margins = { left = dpi(15), right = dpi(15) },
            {
                layout = wibox.layout.align.horizontal,
                {
                    id = "label-background",
                    widget = wibox.container.background,
                    {
                        layout = wibox.layout.fixed.horizontal,
                        spacing = dpi(15),
                        {
                            widget = wibox.container.place,
                            valign = "center",
                            {
                                widget = wibox.widget.imagebox,
                                image = gcolor.recolor_image(icon, beautiful.fg),
                                forced_height = dpi(24),
                                forced_width = dpi(24),
                                resize = true,
                            },
                        },
                        {
                            widget = wibox.container.place,
                            valign = "center",
                            {
                                layout = wibox.layout.fixed.vertical,
                                {
                                    id = "label",
                                    widget = wibox.widget.textbox,
                                    markup = description,
                                },
                                {
                                    id = "description",
                                    widget = wibox.widget.textbox,
                                    font = beautiful.font_name .. dpi(9),
                                },
                            },
                        },
                    },
                },
                nil,
                {
                    layout = wibox.layout.fixed.horizontal,
                    {
                        widget = wibox.container.margin,
                        forced_height = 1,
                        forced_width = beautiful.separator_thickness,
                        margins = { top = dpi(12), bottom = dpi(12) },
                        {
                            id = "separator",
                            widget = wibox.widget.separator,
                            orientation = "vertical",
                        },
                    },
                    {
                        id = "reveal-button",
                        widget = wibox.container.background,
                        forced_width = dpi(45),
                        {
                            widget = wibox.container.place,
                            valign = "center",
                            halign = "center",
                            {
                                widget = wibox.container.margin,
                                margins = dpi(6),
                                {
                                    widget = wibox.widget.imagebox,
                                    image = gcolor.recolor_image(
                                        arrow_icon
                                            or (beautiful.theme_path
                                                .. "/icons/wibar/arrow-right.svg"),
                                        beautiful.fg
                                    ),
                                },
                            },
                        },
                    },
                },
            },
        },
    })

    local label_background = ret:get_children_by_id("label-background")[1]
    if handler then
        label_background:buttons({
            awful.button({}, 1, handler),
        })
    end

    local separator = ret:get_children_by_id("separator")[1]

    local function on_state_change(self, state)
        local description_widget = self:get_children_by_id("description")[1]

        if state then
            self:set_bg(beautiful.ac)
            self:set_fg(beautiful.fg)
            separator:set_color(beautiful.bg)
            description_widget:set_markup(active_text or "Active")
        else
            self:set_bg(beautiful.bg_alt)
            self:set_fg(beautiful.fg)
            separator:set_color(beautiful.bg_urg)
            description_widget:set_markup(inactive_text or "Inactive")
        end
    end

    if adapter and powered_signal then
        local reveal_button = ret:get_children_by_id("reveal-button")[1]

        local function get_powered_state()
            if adapter.get_powered then
                return adapter:get_powered()
            elseif adapter.get_wireless_enabled then
                return adapter:get_wireless_enabled()
            end
            return false
        end

        reveal_button:buttons({
            awful.button({}, 1, function()
                local powered_state = get_powered_state()
                if powered_state then
                    if power_handler then
                        power_handler(adapter)
                    end
                else
                    if adapter.unblock then
                        adapter:unblock(function()
                            adapter:set_powered(true)
                        end)
                    else
                        adapter:set_powered(true)
                    end
                end
            end),
        })

        ret:connect_signal("mouse::enter", function(w)
            if not get_powered_state() then
                w:set_bg(beautiful.bg_urg)
                separator:set_color(beautiful.fg_alt)
            end
        end)

        ret:connect_signal("mouse::leave", function(w)
            if not get_powered_state() then
                w:set_bg(beautiful.bg_alt)
                separator:set_color(beautiful.bg_urg)
            end
        end)

        adapter:connect_signal(powered_signal, function(_, state)
            on_state_change(ret, state)
        end)

        on_state_change(ret, get_powered_state())
    else
        ret:connect_signal("mouse::enter", function(w)
            w:set_bg(beautiful.bg_urg)
        end)
        ret:connect_signal("mouse::leave", function(w)
            w:set_bg(nil)
        end)
    end

    return ret
end

return setmetatable({}, { __call = new })