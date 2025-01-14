--
-- Provides:
-- widget::preview::update   -- first line is the signal
--      t   (tag)               -- indented lines are function parameters
-- widget::preview::visibility
--      s   (screen)
--      v   (boolean)
--
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local cairo = require("lgi").cairo

local function draw_widget(
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
    background_image
)
    local client_list = wibox.layout.manual()
    local client_count = 0
    local tag_text_box = wibox.widget{
        text = t.name,
        widget = wibox.widget.textbox,
        align = 'center',
        valign = 'center'
    }

    local tag_text_bg = wibox.widget{
        {
            tag_text_box,
            margins = 5,
             widget = wibox.container.margin
        },
        bg = "#222222",
        shape =  function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, dpi(5))
            end,
        widget = wibox.container.background
    }
    client_list.forced_height = geo.height
    client_list.forced_width = geo.width
    local tag_screen = t.screen
    for i, c in ipairs(t:clients()) do
        if not c.hidden and not c.minimized then
            client_count = client_count + 1
            local img_box = wibox.widget ({
                resize = true,
                forced_height = 100 * scale,
                forced_width = 100 * scale,
                widget = wibox.widget.imagebox,
            })

			-- If fails to set image, fallback to a awesome icon
			if not pcall(function() img_box.image = gears.surface.load(c.icon) end) then
				img_box.image = beautiful.theme_assets.awesome_icon (24, "#222222", "#fafafa")
			end

            if tag_preview_image then
               local content = gears.surface(c.content)
                local cr = cairo.Context(content)
                local x, y, w, h = cr:clip_extents()
                local img = cairo.ImageSurface.create(
                    cairo.Format.ARGB32,
                    w - x,
                    h - y
                )
                cr = cairo.Context(img)
                cr:set_source_surface(content, 0, 0)
                cr.operator = cairo.Operator.SOURCE
                cr:paint()

                img_box = wibox.widget({
                    image = gears.surface.load(img),
                    resize = true,
                    opacity = client_opacity,
                    forced_height = math.floor(c.height * scale),
                    forced_width = math.floor(c.width * scale),
                    widget = wibox.widget.imagebox,
                })

            end

            local client_box = wibox.widget({
                {
                    nil,
                    {
                        nil,
                        img_box,
                        nil,
                        expand = "outside",
                        layout = wibox.layout.align.horizontal,
                    },
                    nil,
                    expand = "outside",
                    widget = wibox.layout.align.vertical,
                },
                forced_height = math.floor(c.height * scale),
                forced_width = math.floor(c.width * scale),
                bg = client_bg,
                shape_border_color = client_border_color,
                shape_border_width = client_border_width,
               shape = function(cr, width, height)
                    gears.shape.rounded_rect(cr, width, height, client_radius)
                end,
                widget = wibox.container.background,
            })

            client_box.point = {
                x = math.floor((c.x - geo.x) * scale),
                y = math.floor((c.y - geo.y) * scale),
            }

            client_list:add(client_box)
        end
    end

    return wibox.widget {
        {
            background_image,
            {
                {
                    {
                        {
                            client_list,
                            forced_height = geo.height,
                            forced_width = geo.width,
                            widget = wibox.container.place,
                        },
                         {
                             tag_text_bg,
                             widget = wibox.container.place,
                         },
                        layout = wibox.layout.stack,
                    },
                    layout = wibox.layout.align.vertical,
                },
                margins = margin,
                widget = wibox.container.margin,
            },
            layout = wibox.layout.stack
        },
        bg = widget_bg,
        shape_border_width = widget_border_width,
         shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, screen_radius)
            end,
        shape_border_color = widget_border_color,
        widget = wibox.container.background,
    }
end

    local tag_preview_image = true
    local widget_x = dpi(20)
    local widget_y =  dpi(20)
    local scale = 0.2
    local work_area = false
    local padding =  false
    local placement_fn =nil
    local background_image =  nil

    local margin = dpi(0)
    local screen_radius =  dpi(0)
    local client_radius =  dpi(0)
    local client_opacity =0.5
    local client_bg = "#44444499"
    local client_border_color = "#ffffff"
    local client_border_width =dpi(3)
    local widget_bg = "#00000099"
    local widget_border_color ="#ffffff66"
    local widget_border_width =dpi(2)

    local tag_preview_box = awful.popup({
        type = "dropdown_menu",
        visible = false,
        ontop = true,
        placement = placement_fn,
        widget = wibox.container.background,
        input_passthrough = true,
        bg = "#00000000",
    })

    awesome.connect_signal("widget::preview::update", function(t)
        local geo = t.screen:get_bounding_geometry({
            honor_padding = padding,
            honor_workarea = work_area,
        })

        tag_preview_box.maximum_width = scale * geo.width + margin * 2
        tag_preview_box.maximum_height = scale * geo.height + margin * 2

        tag_preview_box.widget = draw_widget(
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
            background_image
        )
    end)

   awesome.connect_signal("widget::preview::visibility", function(s, v)
        if not placement_fn then
            tag_preview_box.x = s.geometry.x + widget_x
            tag_preview_box.y = s.geometry.y + widget_y
        end

        if v == false then
            tag_preview_box.widget = nil
            collectgarbage("collect")
        end

        tag_preview_box.visible = v
    end)

return { draw_widget = draw_widget}
