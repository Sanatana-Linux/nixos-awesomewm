-- NOTE: thanks again to bling, its like stack but has a tab bar on the top. I removed settings I can configure here, refactored it and commented it all pretty as well.
--
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local screen = screen
local tag = tag
local client = client
-- Define the module
local mstab = {}

-- Configuration parameters with fallback

mstab.name = "mstab"
local tabbar_disable = false
local tabbar_ontop = false
local tabbar_padding = "default"
local border_radius = dpi(4)
local tabbar_position = "top"
local bar = require("ui.tabbar")
local tabbar_size = dpi(24)
local dont_resize_slaves = false

-- Initialize top index for each tag
---@diagnostic disable-next-line: undefined-global
for _, tag in ipairs(root.tags()) do
    tag.top_idx = 1
end

-- Set top index when a tag is selected
tag.connect_signal("property::selected", function(t)
    if not t.top_idx then
        t.top_idx = 1
    end
end)

-- Function to update the tabbar
local function update_tabbar(
    clients,
    t,
    top_idx,
    area,
    master_area_width,
    slave_area_width,
    focused_is_slave
)
    local s = t.screen
    local clientlist = bar.layout()

    for idx, c in ipairs(clients) do
        local buttons = gears.table.join(
            awful.button({}, 1, function()
                c:raise()
                client.focus = c
            end),
            awful.button({}, 2, function()
                c:kill()
            end),
            awful.button({}, 3, function()
                c.minimized = true
            end)
        )
        local client_box = bar.create(c, (idx == top_idx), buttons)
        clientlist:add(client_box)
    end

    if not s.tabbar then
        s.tabbar = wibox({
            ontop = tabbar_ontop,
            visible = true,
        })

        local function adjust_visibility()
            local name = awful.layout.getname(awful.layout.get(s))
            s.tabbar.visible = (name == mstab.name)
        end

        -- Connect signals for visibility adjustments
        local signals = {
            "property::selected",
            "property::layout",
            "tagged",
            "untagged",
            "property::master_count",
            "property::minimized",
        }
        for _, signal in ipairs(signals) do
            tag.connect_signal(signal, adjust_visibility)
        end
    end

    -- Determine which background to use for the entire tabbar
    local container_bg = focused_is_slave and bar.bg_focus or bar.bg_normal

    -- Correctly set the widget for the tabbar wibox
    s.tabbar:set_widget({
        widget = wibox.container.background,
        bg = container_bg,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, border_radius)
        end,
        -- The child widget is the list of clients
        clientlist,
    })

    -- Update tabbar size and position
    local tabbar_x, tabbar_y, tabbar_width, tabbar_height
    if tabbar_position == "top" then
        tabbar_x, tabbar_y, tabbar_width, tabbar_height =
            area.x + master_area_width + t.gap,
            area.y + t.gap,
            slave_area_width - 2 * t.gap,
            tabbar_size
    elseif tabbar_position == "bottom" then
        tabbar_x, tabbar_y, tabbar_width, tabbar_height =
            area.x + master_area_width + t.gap,
            area.y + area.height - tabbar_size - t.gap,
            slave_area_width - 2 * t.gap,
            tabbar_size
    elseif tabbar_position == "left" then
        tabbar_x, tabbar_y, tabbar_width, tabbar_height =
            area.x + master_area_width + t.gap,
            area.y + t.gap,
            tabbar_size,
            area.height - 2 * t.gap
    elseif tabbar_position == "right" then
        tabbar_x, tabbar_y, tabbar_width, tabbar_height =
            area.x + master_area_width + slave_area_width - tabbar_size - t.gap,
            area.y + t.gap,
            tabbar_size,
            area.height - 2 * t.gap
    end

    s.tabbar.x, s.tabbar.y, s.tabbar.width, s.tabbar.height =
        tabbar_x, tabbar_y, tabbar_width, tabbar_height
end

-- Arrange function for the layout
function mstab.arrange(p)
    local area = p.workarea
    local t = p.tag or screen[p.screen].selected_tag
    local s = t.screen
    local mwfact = t.master_width_factor
    local nmaster = math.min(t.master_count, #p.clients)
    local nslaves = #p.clients - nmaster

    local master_area_width = area.width * mwfact
    local slave_area_width = area.width - master_area_width

    if tabbar_padding == "default" then
        tabbar_padding = 2 * t.gap
    end

    if nmaster == 0 then
        master_area_width, slave_area_width = 1, area.width
    end

    if nslaves <= 1 then
        if s.tabbar then
            s.tabbar.visible = false
        end
        awful.layout.suit.tile.right.arrange(p)
        return
    end

    for idx = 1, nmaster do
        local c = p.clients[idx]
        local g = {
            x = area.x,
            y = area.y + (idx - 1) * (area.height / nmaster),
            width = master_area_width,
            height = area.height / nmaster,
        }
        p.geometries[c] = g
    end

    local tabbar_size_change, tabbar_width_change, tabbar_y_change, tabbar_x_change =
        0, 0, 0, 0
    if not tabbar_disable then
        tabbar_size_change, tabbar_y_change =
            tabbar_size + tabbar_padding, tabbar_size + tabbar_padding
    end

    local slave_clients = {}
    local focused_is_slave = false
    for idx = 1, nslaves do
        local c = p.clients[idx + nmaster]
        slave_clients[#slave_clients + 1] = c
        if c == client.focus then
            t.top_idx = #slave_clients
            focused_is_slave = true
        end
        local g = {
            x = area.x + master_area_width + tabbar_x_change,
            y = area.y + tabbar_y_change,
            width = slave_area_width - tabbar_width_change,
            height = area.height - tabbar_size_change,
        }
        if not dont_resize_slaves and idx ~= t.top_idx then
            g = {
                x = area.x + master_area_width + slave_area_width / 4,
                y = area.y + tabbar_size + area.height / 4,
                width = slave_area_width / 2,
                height = area.height / 4 - tabbar_size,
            }
        end
        p.geometries[c] = g
    end

    if not tabbar_disable then
        update_tabbar(
            slave_clients,
            t,
            t.top_idx,
            area,
            master_area_width,
            slave_area_width,
            focused_is_slave
        )
    end
end

return mstab
