--  _______         __                        __
-- |    |  |.-----.|  |_.--.--.--.-----.----.|  |--.
-- |       ||  -__||   _|  |  |  |  _  |   _||    <
-- |__|____||_____||____|________|_____|__|  |__|__|
--  ______               __
-- |      |.-----.-----.|  |_.-----.----.
-- |   ---||  -__|     ||   _|  -__|   _|
-- |______||_____|__|__||____|_____|__|
-- ------------------------------------------------- --
-- popup that lists wifi networks and currently connected network.
-- local screen_geometry = require('awful').screen.focused().geometry

-- ------------------------------------------------- --
awful.screen.connect_for_each_screen(
    function(s)
        -- ------------------------------------------------- --
        network =
            wibox(
            {
                type = 'dock',
                shape = beautiful.client_shape_rounded_xl,
                screen = s,
                width = dpi(380),
                height = dpi(580),
                bg = beautiful.bg_color,
                margins = dpi(20),
                ontop = true,
                visible = false
            }
        )
        -- ------------------------------------------------- --
        -- widgets

        local title =
            wibox.widget {
            {
                {
                    spacing = dpi(0),
                    layout = wibox.layout.align.vertical,
                    expand = 'max',
                    widget = wibox.container.margin,
                    {
                        halign = 'center',
                        valign = 'center',
                        layout = wibox.layout.align.horizontal,
                        spacing = dpi(16),
                        {
                            {
                                nil,
                                {
                                    image = icons.wifi_3,
                                    widget = wibox.ui.bar.popups.network.widgets.imagebox,
                                    forced_height = dpi(15),
                                    id = 'icon',
                                    resize = true
                                },
                                nil,
                                halign = 'center',
                                valign = 'center',
                                forced_height = dpi(30),
                                layout = wibox.layout.align.vertical
                            },
                            widget = wibox.container.margin,
                            margins = dpi(15)
                        },
                        require('ui.bar.popups.network.widgets.network_center.title-text')
                    }
                },
                margins = dpi(5),
                widget = wibox.container.margin
            },
            shape = beautiful.client_shape_rounded_xl,
            bg = beautiful.bg_panel,
            forced_width = dpi(380),
            forced_height = dpi(70),
            ontop = true,
            border_width = dpi(2),
            border_color = colors.alpha(colors.black, 'cc'),
            widget = wibox.container.background
        }
        -- ------------------------------------------------- --
        local status =
            wibox.widget {
            {
                {
                    spacing = dpi(0),
                    layout = wibox.layout.fixed.vertical,
                    format_item(
                        {
                            layout = wibox.layout.fixed.horizontal,
                            spacing = dpi(16),
                            require('ui.bar.popups.network.widgets.network_center.status-icon'),
                            require('ui.bar.popups.network.widgets.network_center.status')
                        }
                    )
                },
                margins = dpi(5),
                widget = wibox.container.margin
            },
            shape = beautiful.client_shape_rounded_xl,
            bg = beautiful.bg_normal,
            forced_width = dpi(380),
            forced_height = 70,
            ontop = true,
            border_width = dpi(2),
            border_color = colors.alpha(colors.black, 'cc'),
            widget = wibox.container.background
        }
        -- ------------------------------------------------- --
        local networks_panel =
            wibox.widget {
            {
                {
                    spacing = dpi(0),
                    layout = wibox.layout.flex.vertical,
                    format_item(
                        {
                            layout = wibox.layout.fixed.horizontal,
                            spacing = dpi(16),
                            require('ui.bar.popups.network.widgets.network_center.networks-panel')
                        }
                    )
                },
                margins = dpi(5),
                widget = wibox.container.margin
            },
            shape = beautiful.client_shape_rounded_xl,
            bg = beautiful.bg_menu,
            forced_width = dpi(380),
            ontop = true,
            border_width = dpi(2),
            border_color = colors.alpha(colors.black, 'cc'),
            widget = wibox.container.background
        }

        -- animations
        --------------
        local slide_right =
            rubato.timed {
            pos = s.geometry.height,
            rate = 60,
            intro = 0.14,
            duration = 0.33,
            subscribed = function(pos)
                network.y = s.geometry.y + pos
            end
        }

        local slide_end =
            gears.timer(
            {
                single_shot = true,
                timeout = 0.33 + 0.08,
                callback = function()
                    network.visible = false
                end
            }
        )

        -- toggler script
        --~~~~~~~~~~~~~~~
        local screen_backup = 1

        nc_toggle = function(screen)
            -- set screen to default, if none were found
            if not screen then
                screen = awful.screen.focused()
            end

            -- control center x position
            network.x = screen.geometry.x + (dpi(405) + beautiful.useless_gap * 4)

            -- toggle visibility
            if network.visible then
                -- check if screen is different or the same
                if screen_backup ~= screen.index then
                    network.visible = true
                else
                    slide_end:again()
                    slide_right.target = s.geometry.height
                end
            elseif not network.visible then
                slide_right.target = s.geometry.height - (network.height + beautiful.useless_gap * 2)
                network.visible = true
            end

            -- set screen_backup to new screen
            screen_backup = screen.index
        end
        -- Eof toggler script
        --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        net_off = function(screen)
            if network.visible then
                slide_end:again()
                slide_right.target = s.geometry.height
            end
        end
        -- function to show/hide extra buttons
        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        function show_extra_control_stuff(input)
            if input then
                awesome.emit_signal('network::center::extras', true)
                network.height = dpi(715)
                readwrite.write('cc_state', 'open')
            else
                awesome.emit_signal('network::center::extras', false)
                network.height = dpi(580)
                readwrite.write('cc_state', 'closed')
            end
            slide_right.target = s.geometry.height - (network.height + beautiful.useless_gap * 2)
        end

        -- Initial setup
        network:setup {
            {
                {
                    {
                        nil,
                        title,
                        layout = wibox.layout.align.horizontal
                    },
                    status,
                    networks_panel,
                    layout = wibox.layout.fixed.vertical,
                    spacing = dpi(24)
                },
                widget = wibox.container.margin,
                margins = dpi(20)
            },
            layout = wibox.layout.fixed.vertical
        }
    end
)
