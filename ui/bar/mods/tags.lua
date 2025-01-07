local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")

local function new(s)
    if not s or not s.valid then
        print("Error: Invalid screen object passed to taglist.")
        return wibox.widget.textbox("Invalid Screen") -- Return a placeholder widget
    end
    local taglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.selected,
        style = {
            shape = helpers.rrect(beautiful.border_radius),
        },
        widget_template = {
            {
                {
                    helpers.colorizeText( "Workspace ", beautiful.fg_normal ),
                    {
                        id = "text_role",
                        widget = wibox.widget.textbox
                    },
                    layout = wibox.layout.fixed.horizontal
                },
                top = dpi(5),
                bottom = dpi(5),
                left = dpi(8),
                right = dpi(8),
                widget = wibox.container.margin
            },
            id = "background_role",
            widget = wibox.container.background,
            create_callback = function(self)
                helpers.addHover(self)
            end
        },
        buttons = {
            awful.button({ }, 1, function()
                awesome.emit_signal("widget::preview")
            end),
        }
    }
    taglist:set_base_layout() --explicitly set the base layout
    return taglist
end

return new
