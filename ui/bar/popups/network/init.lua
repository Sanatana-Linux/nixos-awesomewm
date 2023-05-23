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
                shape = utilities.mkroundedrect(),
                screen = s,
                width = dpi(380),
                height = dpi(560),
                bg = beautiful.bg_normal .. 'cc',
                border_color = beautiful.grey .. 'cc',
                border_width = dpi(2),
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
                        spacing = dpi(26),
                        {
                            {
                                nil,
                                {
                                    image = icons.wifi_problem,
                                    widget = wibox.widget.imagebox,
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
                        require('ui.bar.popups.network.widgets.title-text')
                    }
                },
                margins = dpi(5),
                widget = wibox.container.margin
            },
            shape = utilities.mkroundedrect(),
            bg = beautiful.black .. '77',
            forced_width = dpi(380),
            forced_height = dpi(70),
            ontop = true,
            border_width = dpi(2),
            border_color = beautiful.grey .. 'cc',
            widget = wibox.container.background
        }
        -- ------------------------------------------------- --
        local status =
            wibox.widget {
            {
                {
                    spacing = dpi(0),
                    layout = wibox.layout.fixed.vertical,
                 
                        {
                            layout = wibox.layout.fixed.horizontal,
                            spacing = dpi(16),
                            require('ui.bar.popups.network.widgets.status-icon'),
                            require('ui.bar.popups.network.widgets.status')
                        }
                    
                },
                margins = dpi(5),
                widget = wibox.container.margin
            },
            shape = utilities.mkroundedrect(),
            bg = beautiful.black .. '77',
            forced_width = dpi(380),
            forced_height = dpi(50),
            ontop = true,
            border_width = dpi(2),
            border_color = beautiful.grey .. 'cc',
            widget = wibox.container.background
        }
        -- ------------------------------------------------- --
        local networks_panel =
            wibox.widget {
            {
                {
                    spacing = dpi(0),
                    layout = wibox.layout.flex.vertical,
                        {
                            layout = wibox.layout.fixed.horizontal,
                            spacing = dpi(16),
                            require('ui.bar.popups.network.widgets.networks-panel')
                        }

                },
                margins = dpi(5),
                widget = wibox.container.margin
            },
            shape = utilities.mkroundedrect(),
            bg = beautiful.bg_normal .. '33',
            forced_width = dpi(380),
            ontop = true,
            border_width = dpi(2),
            border_color = beautiful.grey .. 'cc',
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
                network.y = ( s.geometry.y - beautiful.bar_height) + pos
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
            network.x = screen.geometry.x + (dpi(905) + beautiful.useless_gap * 4)
            

            -- toggle visibility
            if network.visible then
                -- check if screen is different or the same
                if screen_backup ~= screen.index then
                    network.visible = true
                    net_kg:start()
                else
                    net_kg:stop()
                    slide_end:again()
                    slide_right.target = s.geometry.height
                end
            elseif not network.visible then
                slide_right.target = s.geometry.height - (network.height + beautiful.useless_gap * 2)
                network.visible = true
                net_kg:start()
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
       -- -------------------------------------------------------------------------- --
  -- creates a keygrabber so the user can close the 
  -- thing without pressing the button again
  -- 
  net_kg = awful.keygrabber {
    keybindings = {
      awful.key {
        modifiers = {},
        key = "Escape",
        on_press = function()
          nc_toggle()
          net_kg:stop()
        end
      },
      awful.key {
        modifiers = {},
        key = "q",
        on_press = function()
          nc_toggle()
          net_kg:stop()
        end
      },
      awful.key {
        modifiers = {},
        key = "x",
        on_press = function()
          nc_toggle()
          net_kg:stop()
        end
      }
    }
  }

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
