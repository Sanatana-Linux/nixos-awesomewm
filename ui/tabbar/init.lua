--- Tab bar for the `mstab` (master-stack with tabbed slaves) layout.
-- Rendered as a second titlebar on the top of the screen with one entry per
-- master client plus its tabbed slaves. Uses
-- `awful.titlebar.widget.iconwidget` / `titlewidget` to render the icon and
-- title from the underlying client.
-- @module ui.tabbar

-- NOTE: Thanks again bling
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")
local awful = require("awful")
local size = dpi(28) -- Set the size
local position = "top" -- Set the position to default to "top" if not s

--------------------------------------------------------------------> signal ;

--|switching or loginspecified

--- Build a single tab widget for a client.
-- Combines the client's icon (left) and title (right) into a
-- compact horizontal layout. The background swaps to the focused
-- gradient when the client has focus. Adds a tooltip with the
-- full window title.
-- @tparam client c The client to render a tab for
-- @tparam boolean focused_bool Whether `c` is the focused client
-- @tparam table buttons awful.button bindings for the tab
-- @treturn table A wibox widget
local function create(c, focused_bool, buttons)
    local bg_normal = beautiful.bg_gradient_titlebar
    local bg_focus = beautiful.bg_gradient_titlebar_alt
    local bg_temp = focused_bool and bg_focus or bg_normal
    local fg_temp = focused_bool and beautiful.fg or beautiful.fg

    -- Create the tabbar widget
    local wid_temp = wibox.widget({
        {
            { -- Left: Icon
                wibox.widget.base.make_widget(
                    awful.titlebar.widget.iconwidget(c)
                ),
                buttons = buttons,
                layout = wibox.layout.fixed.horizontal,
            },
            { -- Title
                wibox.widget.base.make_widget(
                    awful.titlebar.widget.titlewidget(c)
                ),
                buttons = buttons,
                widget = wibox.container.place,
            },
            nil, -- Right: No buttons needed
            layout = wibox.layout.align.horizontal,
        },
        bg = bg_temp,
        fg = fg_temp,
        widget = wibox.container.background,
    })

    -- Add tooltip with full window title
    local tooltip = awful.tooltip({
        objects = { wid_temp },
        text = c.name or c.class or "Unknown Window",
        delay_show = 0.5,
        margins_topbottom = dpi(8),
        margins_leftright = dpi(12),
        bg = beautiful.bg .. "33",
        fg = beautiful.fg,
    })

    -- Update tooltip when client name changes
    c:connect_signal("property::name", function()
        tooltip:set_text(c.name or c.class or "Unknown Window")
    end)

    return wid_temp -- Return the created tabbar widget
end

--- @table _ M Tab bar configuration table consumed by `awful.titlebar.widget`.
-- Keys: `layout` (the wibox layout), `create` (per-client tab builder),
-- `position` ("top"/"bottom"/"left"/"right"), `size` (height in px),
-- `bg_normal`/`bg_focus` (theme colors).
return {
    layout = wibox.layout.flex.horizontal,
    create = create,
    position = position,
    size = size,
    bg_normal = beautiful.bg_gradient_titlebar,
    bg_focus = beautiful.bg_gradient_titlebar_alt,
}
