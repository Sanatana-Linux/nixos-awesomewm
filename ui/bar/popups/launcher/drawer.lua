local freedesktop = require("ui.bar.popups.launcher.freedesktop")
local drawer = {}
-- ------------------------------------------------- --
-- create a table that contains the .desktop information for every program
local programs_list = {}
awful.spawn.with_line_callback(
    -- [[bash -c 'find /usr/share/applications -type f -name "*.desktop"']],
    [[bash -c 'find /run/current-system/sw/share/applications -type f -name "*.desktop"']],

    {
        stdout = function(line)
            table.insert(programs_list, menubar.utils.parse_desktop_file(line))
        end
    }
)
-- ------------------------------------------------- --
local app_drawer =
    wibox.widget {
        widget = wibox.container.margin,
        margins = dpi(10),
        layout=utilities.overflow.vertical(),
        {
    shape = utilities.mkroundedrect(),
    border_width = 0,
    visible = false,
    bg = beautiful.black,
    width = dpi(150),
    height = dpi(350),
    layout = utilities.overflow.vertical(),
    widget = wibox.container.scroll.vertical
        }
}
-- ------------------------------------------------- --
local function generate_drawer()
    local row = {layout = utilities.overflow.horizontal()}
    local rows = {layout = utilities.overflow.vertical()}
    local width_count = 0

    for _, program in pairs(programs_list) do
        local icon_widget =
            wibox.widget {
            {
                {
                    layout = wibox.layout.align.vertical(),
                    {
                        image = program.icon_path,
                        forced_height = icon_size,
                        forced_width = icon_size,
                        widget = wibox.widget.imagebox
                    },
                    {
                        text = string.sub(program.Name, 1, 9) .. '...',
                        font = beautiful.font .. ' 14',
                        widget = wibox.widget.textbox
                    }
                },
                margins = 0,
                layout = wibox.container.margin
            },
            bg = beautiful.black,
            shape = utilities.mkroundedrect(),
            widget = wibox.container.background
        }

        local icon_container =
            wibox.widget {
            icon_widget,
            bg = beautiful.black,
            margins = dpi(15),
            layout = wibox.container.margin
        }

        icon_widget:connect_signal(
            'mouse::enter',
            function(c)
                c:set_bg(beautiful.accent)
            end
        )
        icon_widget:connect_signal(
            'mouse::leave',
            function(c)
                c:set_bg(beautiful.black)
            end
        )

        icon_widget:buttons(
            awful.util.table.join(
                awful.button(
                    {},
                    1,
                    function()
                        awful.spawn(program.cmdline)
                        app_drawer.visible = not app_drawer.visible
                    end
                )
            )
        )

        table.insert(row, icon_container)

        width_count = width_count + 1
        if width_count == 10 then
            width_count = 0
            table.insert(rows, row)
            row = {layout = utilities.overflow.horizontal({step = 20})}
        end
    end

    table.insert(rows, row)

    app_drawer:setup(rows)
end
generate_drawer()

-- ------------------------------------------------- --
app_drawer.drawer_toggle = function(s)
    if app_drawer.visible then
        app_drawer.visible = not app_drawer.visible
    else
        generate_drawer()
        app_drawer.visible = true
        app_drawer.screen = s 
    end
end

return app_drawer
