-- ui.bar.mods.tags.lua
local awful = require("awful")
local wibox = require("wibox")
local helpers = require("helpers")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local preview_widget = require("mods.preview")

-- Define tag_preview_box outside the function scope
local tag_preview_box
local scale = 0.125
local margin = dpi(20)
local tag_preview_image = true
local client_opacity = 0.5
local client_bg = beautiful.bg .. "99"
local client_border_color = beautiful.fg
local client_border_width = dpi(3)
local widget_bg = beautiful.mbg
local widget_border_color = beautiful.fg .. '66'
local widget_border_width = dpi(2)
local screen_radius = dpi(0)
local client_radius = dpi(0)
local tag_spacing = dpi(15)
local hide_preview_timer

local function hide_tag_preview()
    tag_preview_box.visible = false
    collectgarbage("collect")
    if taglist then
        taglist.filter = awful.widget.taglist.filter.selected
    end
end

return function(s)
    local taglist
    local current_tag_index = 1
    local is_mouse_over_preview = false

    tag_preview_box = tag_preview_box or awful.popup({
        type = "dropdown_menu",
        visible = false,
        ontop = true,
        placement = function(c)
            local screen = awful.screen.focused()
            local screen_geo = screen.geometry
            c.x = screen_geo.x + margin
            c.y = screen_geo.height - c.height - dpi(50)
        end,
        widget = wibox.container.background,
        input_passthrough = false,
        bg = "#00000000",
    })

    taglist = awful.widget.taglist({
        layout = {
            spacing = dpi(30),
            layout = wibox.layout.fixed.horizontal,
        },
        screen = s,
        filter = awful.widget.taglist.filter.selected,
        buttons = {},
        widget_template = {
            {
                {
                    {
                        {
                            id     = 'text_role',
                            widget = wibox.widget.textbox,
                            font   = beautiful.prompt_font .. '16',

                        },
                        -- Force the textbox to fit its content
                        fit = true,
                        strategy = "fit",
                        -- Center the content within the textbox
                        widget = wibox.container.place,
                        halign = 'center',
                        valign = 'center',
                    },
                    -- Wrap in a margin container to add padding
                    widget = wibox.container.margin,
                    right = dpi(5),
                    left = dpi(5),
                },
                -- Center the margin container vertically
                widget = wibox.container.place,
                valign = "center",
                halign = "center",
            },
            bg = beautiful.bg_gradient_button,
            forced_width = dpi(40),
            widget = wibox.container.background,
            shape = helpers.rrect(beautiful.border_radius),
            border_width = dpi(1),
            border_color = beautiful.fg .. "66",
        },
        widget = wibox.container.margin,
        left = dpi(5),
        right = dpi(5),
        top = dpi(5),
        bottom = dpi(5),
    })


    taglist.full_preview_showing = false
    taglist.hover_preview_showing = false

    taglist:connect_signal("mouse::enter", function()
        taglist.bg = beautiful.bg_gradient_button_alt
        taglist.hover_preview_showing = true
        if hide_preview_timer then
            hide_preview_timer:stop()
            hide_preview_timer = nil
        end

        local screen_geo = s:get_bounding_geometry({
            honor_padding = false,
            honor_workarea = false,
        })
        local geo = {
            x = 0,
            y = 0,
            width = screen_geo.width * scale,
            height = screen_geo.height * scale
        }

        local widget_to_display = wibox.widget {
            layout = wibox.layout.fixed.horizontal,
            spacing = tag_spacing
        }

        local tags = awful.screen.focused().tags
        for i, t in ipairs(tags) do
            local widget = preview_widget.draw_widget(
                t,
                tag_preview_image,
                scale,
                screen_radius,
                client_radius,
                client_opacity,
                client_bg,
                client_border_color,
                client_border_width,
                widget_bg,
                widget_border_color,
                widget_border_width,
                geo,
                margin,
                nil
            )
            widget:connect_signal("button::press", function(_, _, _, button)
                if button == 1 then
                    t:view_only()
                    hide_tag_preview()
                end
            end)

            widget_to_display:add(widget)
        end

        for i, t in ipairs(tags) do
            if t.selected then
                current_tag_index = i
            end
        end

        tag_preview_box.widget = widget_to_display
        taglist.filter = awful.widget.taglist.filter.all
        tag_preview_box.height = geo.height + (margin * 2)
        tag_preview_box.visible = true
    end)

    taglist:connect_signal("mouse::leave", function()
        taglist.bg = beautiful.bg_gradient_button
        taglist.hover_preview_showing = false
        if not is_mouse_over_preview then
            if hide_preview_timer then
                hide_preview_timer:stop()
            end
            hide_preview_timer = gears.timer {
                timeout = 3,
                autostart = true,
                single_shot = true,
                callback = hide_tag_preview
            }
        end
    end)

    tag_preview_box:connect_signal("mouse::enter", function()
        is_mouse_over_preview = true
        if hide_preview_timer then
            hide_preview_timer:stop()
            hide_preview_timer = nil
        end
    end)

    tag_preview_box:connect_signal("mouse::leave", function()
        is_mouse_over_preview = false
        if hide_preview_timer then
            hide_preview_timer:stop()
        end
        hide_preview_timer = gears.timer {
            timeout = 3,
            autostart = true,
            single_shot = true,
            callback = hide_tag_preview
        }
    end)

    return taglist
end
