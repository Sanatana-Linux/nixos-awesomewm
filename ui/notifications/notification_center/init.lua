--  _______         __                        __
-- |    |  |.-----.|  |_.--.--.--.-----.----.|  |--.
-- |       ||  -__||   _|  |  |  |  _  |   _||    <
-- |__|____||_____||____|________|_____|__|  |__|__|
--  ______               __
-- |      |.-----.-----.|  |_.-----.----.
-- |   ---||  -__|     ||   _|  -__|   _|
-- |______||_____|__|__||____|_____|__|
-- ------------------------------------------------- --
-- NOTE popup displaying notification
-- ------------------------------------------------- --
awful.screen.connect_for_each_screen(
    function(s)
        -- ------------------------------------------------- --

        local notification_center =
            wibox(
            {
                type = 'dock',
                shape = utilities.mkroundedrect(),
                screen = s,
                width = dpi(380),
                height = dpi(580),
                bg = beautiful.bg_normal,
                margins = dpi(20),
                ontop = true,
                visible = false
            }
        )
        -- ------------------------------------------------- --
        -- -------------------- widgets -------------------- --

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
                                    image = icons.notifications,
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
                        require('ui.notifications.notification_center.notifications_center.title-text'),
                        require('ui.notifications.notification_center.notifications_center.clear-all')
                    }
                },
                margins = dpi(5),
                widget = wibox.container.margin
            },
            shape = utilities.mkroundedrect(),
            bg = beautiful.bg_panel,
            forced_width = dpi(380),
            forced_height = dpi(70),
            ontop = true,
            border_width = dpi(2),
            border_color = beautiful.grey,
            widget = wibox.container.background
        }
        -- ------------------------------------------------- --
        -- -------------- panel with controls -------------- --
        local notification_panel =
            wibox.widget {
            {
                {
                    spacing = dpi(12),
                    layout = wibox.layout.fixed.vertical,
                    {
                        layout = wibox.layout.fixed.horizontal,
                        spacing = dpi(16),
                        require('ui.notifications.notification_center.notifications_center.notifications-panel'),
                        bg = beautiful.bg_panel
                    }
                },
                margins = dpi(12),
                widget = wibox.container.margin
            },
            shape = utilities.mkroundedrect(),
            widget = wibox.container.background
        }

        -- ------------------------------------------------- --
        -- ------------------- animations ------------------ --

        local slide_right =
            rubato.timed {
            pos = s.geometry.height,
            rate = 60,
            intro = 0.14,
            duration = 0.33,
            subscribed = function(pos)
                notification_center.y = s.geometry.y + pos
            end
        }

        local slide_end =
            gears.timer(
            {
                single_shot = true,
                timeout = 0.33 + 0.08,
                callback = function()
                    notification_center.visible = false
                end
            }
        )
        -- ------------------------------------------------- --
        -- ----------------- toggler script ---------------- --

        local screen_backup = 1

        not_toggle = function(screen)
            -- NOTE set screen to default, if none were found
            if not screen then
                screen = awful.screen.focused()
            end

            -- NOTE controlutilities.mkroundedrect()_xl, center x position
            notification_center.x = screen.geometry.x + (dpi(790) + beautiful.useless_gap * 4)

            -- NOTE toggle visibility
            if notification_center.visible then
                -- NOTE check if screen is different or the same
                if screen_backup ~= screen.index then
                    notification_center.visible = true
                    _G.nc_status = 1
                else
                    slide_end:again()
                    slide_right.target = s.geometry.height
                    _G.nc_status = nil
                end
            elseif not notification_center.visible then
                slide_right.target = s.geometry.height - (notification_center.height + beautiful.useless_gap * 2)
                notification_center.visible = true
                _G.nc_status = 1
            end

            -- NOTE set screen_backup to new screen
            screen_backup = screen.index
        end
        -- ------------------------------------------------- --
        -- --------------- Notifications Off --------------- --
        not_off = function(screen)
            if notification_center.visible then
                -- NOTE check if screen is different or the same
                slide_end:again()
                slide_right.target = s.geometry.height
                _G.nc_status = nil
            end
        end

        -- ------------------------------------------------- --
        -- ----------------- Initial setup ----------------- --
        notification_center:setup {
            {
                {
                    {
                        nil,
                        title,
                        layout = wibox.layout.align.horizontal
                    },
                    notification_panel,
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
