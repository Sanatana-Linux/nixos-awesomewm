---@diagnostic disable: undefined-global
--[[
    AwesomeWM Custom Menu Module

    This module provides a hierarchical popup menu implementation for AwesomeWM.
    Features:
      - Keyboard and mouse navigation
      - Customizable appearance via theme
      - Supports nested submenus
      - Executes actions on selection

    Usage:
      local menu = require("modules.menu")
      local my_menu = menu({
        items = {
          { label = "Item 1", exec = function() ... end },
          { label = "Submenu", items = { ... } },
        }
      })
      my_menu:show()
]]

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local capi = { mouse = mouse }
local dpi = beautiful.xresources.apply_dpi
local text_icons = beautiful.text_icons
local shapes = require("modules.shapes")
local click_to_hide = require("modules.click_to_hide")

--- Menu object table
local menu = {}

--- Key bindings for menu navigation
local keys = {
    up = { "Up" },
    down = { "Down" },
    left = { "Left" },
    right = { "Right" },
    exec = { "Return" },
}

--- Update visual state of menu items based on selection
-- @param self menu instance
local function update_items(self)
    local wp = self._private
    local theme = wp.theme
    local items_layout = self.widget:get_children_by_id("items-layout")[1]
    for i, item in ipairs(items_layout.children) do
        if wp.select_index and i == wp.select_index then
            item:set_bg(theme.item_hover_bg)
            item:set_fg(theme.item_hover_fg)
            item:set_border_color(theme.item_hover_border_color)
        else
            item:set_bg(theme.item_bg)
            item:set_fg(theme.item_fg)
        end
    end
end

--- Handle mouse or key entry into a menu item
-- @param self menu instance
-- @param index item index
-- @param args item arguments
-- @param type "mouse" or "key"
local function on_enter(self, index, args, type)
    if not index or not args then
        return
    end
    local wp = self._private

    wp.select_index = index
    update_items(self)

    if args.items then
        if not wp.children[index] then
            wp.children[index] = self.new(args, self)
        end

        if wp.active_child and wp.active_child ~= wp.children[index] then
            wp.active_child:hide()
        end

        wp.active_child = wp.children[index]

        if not wp.active_child.visible then
            wp.active_child:show()
        end
    else
        if wp.active_child then
            wp.active_child:destroy()
        end
    end

    if not args.items and args.exec and type == "key" then
        args.exec()
        self:get_root():hide()
    end
end

--- Start keygrabber for keyboard navigation
-- @param self menu instance
local function run_keygrabber(self)
    local wp = self._private
    wp.keygrabber = awful.keygrabber.run(function(_, key, event)
        if event ~= "press" then
            return
        end
        if gtable.hasitem(keys.up, key) then
            self:back()
            update_items(self)
        elseif gtable.hasitem(keys.down, key) then
            self:next()
            update_items(self)
        elseif gtable.hasitem(keys.left, key) then
            self:hide()
        elseif gtable.hasitem(keys.right, key) then
            on_enter(self, wp.select_index, wp.args[wp.select_index], "key")
        elseif gtable.hasitem(keys.exec, key) then
            on_enter(self, wp.select_index, wp.args[wp.select_index], "key")
        end
    end)
end

--- Create a menu entry widget
-- @param self menu instance
-- @param index item index
-- @param args item arguments
-- @return wibox widget
local function entry(self, index, args)
    local wp = self._private
    local theme = wp.theme

    local ret = wibox.widget({
        widget = wibox.container.background,
        forced_width = theme.item_width,
        forced_height = theme.item_height,
        shape = theme.item_shape,
        {
            id = "item-content",
            widget = wibox.container.margin,
            margins = theme.item_margins,
        },
    })

    local item_content = ret:get_children_by_id("item-content")[1]

    if args.items then
        item_content:set_widget({
            layout = wibox.layout.fixed.horizontal,
            fill_space = true,
            {
                widget = wibox.widget.textbox,
                font = theme.item_font,
                markup = args.label,
            },
            {
                widget = wibox.container.place,
                halign = "right",
                {
                    widget = wibox.widget.textbox,
                    font = theme.item_font,
                    markup = text_icons.arrow_right,
                },
            },
        })
    else
        item_content:set_widget({
            widget = wibox.widget.textbox,
            font = theme.item_font,
            markup = args.label,
        })
    end

    ret:connect_signal("mouse::enter", function()
        on_enter(self, index, args, "mouse")
    end)

    ret:buttons({
        awful.button({}, 1, function()
            if not args.items and args.exec then
                args.exec()
                self:get_root():hide()
            end
        end),
    })

    return ret
end

--- Set popup coordinates based on mouse and parent menu
-- @param self menu instance
local function set_coords(self)
    local wp = self._private
    local theme = wp.theme

    local m_coords = capi.mouse.coords()
    local m_workarea = capi.mouse.screen.workarea
    local m_workarea_hend = m_workarea.x + m_workarea.width
    local m_workarea_vend = m_workarea.y + m_workarea.height

    if not wp.parent then
        local width = theme.item_width + theme.margins * 2

        local self_items =
            #self.widget:get_children_by_id("items-layout")[1].children
        local self_height = theme.item_height * self_items
            + theme.item_spacing * (self_items - 1)
            + theme.margins * 2

        self.x = m_coords.x + width >= m_workarea_hend
                and m_workarea_hend - width
            or m_coords.x
        self.y = m_coords.y + self_height >= m_workarea_vend
                and m_workarea_vend - self_height
            or m_coords.y
    else
        local root = self:get_root()
        local parent = wp.parent
        local parent_wp = wp.parent._private
        local width = theme.item_width + theme.margins * 2

        local self_items =
            #self.widget:get_children_by_id("items-layout")[1].children
        local self_height = theme.item_height * self_items
            + theme.item_spacing * (self_items - 1)
            + theme.margins * 2

        local parent_items =
            #wp.parent.widget:get_children_by_id("items-layout")[1].children
        local parent_height = theme.item_height * parent_items
            + theme.item_spacing * (parent_items - 1)
            + theme.margins * 2

        self.x = root.x + width * 2 + theme.placement_margin >= m_workarea_hend
                and parent.x - width - theme.placement_margin
            or parent.x + width + theme.placement_margin

        local self_y = parent.y
            + (parent_height - theme.margins * 2 - (parent_items - 1) * theme.item_spacing) / parent_items * (parent_wp.select_index - 1)
            + theme.item_spacing * (parent_wp.select_index - 1)

        self.y = self_y + self_height >= m_workarea_vend
                and parent.y + parent_height - self_height
            or self_y
    end
end

--- Get the root menu instance
-- @return root menu instance
function menu:get_root()
    local wp = self._private
    return wp.parent and menu.get_root(wp.parent) or self
end

--- Destroy all active child menus recursively
function menu:destroy_active_children()
    local child = self._private.active_child
    while child do
        local parent = child
        child = child._private.active_child
        parent:destroy()
    end
end

--- Destroy this menu instance
function menu:destroy()
    self:hide()
    self = nil
end

--- Select next menu item
function menu:next()
    local wp = self._private
    local items_layout = self.widget:get_children_by_id("items-layout")[1]
    if not wp.select_index then
        wp.select_index = 1
    elseif wp.select_index ~= #items_layout.children then
        wp.select_index = wp.select_index + 1
    else
        wp.select_index = 1
    end
end

--- Select previous menu item
function menu:back()
    local wp = self._private
    local items_layout = self.widget:get_children_by_id("items-layout")[1]
    if not wp.select_index then
        wp.select_index = 1
    elseif wp.select_index ~= 1 then
        wp.select_index = wp.select_index - 1
    else
        wp.select_index = #items_layout.children
    end
end

--- Hide the menu and stop keygrabber
function menu:hide()
    local wp = self._private
    if not wp.shown then
        return
    end
    wp.shown = false
    awful.keygrabber.stop(wp.keygrabber)
    wp.select_index = nil
    self:destroy_active_children()
    self.visible = false
end

--- Show the menu and start keygrabber
function menu:show()
    local wp = self._private
    if wp.shown then
        return
    end
    wp.shown = true
    update_items(self)
    self.screen = capi.mouse.screen
    set_coords(self)
    run_keygrabber(self)
    self.visible = true
end

--- Toggle menu visibility
function menu:toggle()
    if not self.visible then
        self:show()
    else
        self:hide()
    end
end

--- Create a new menu instance
-- @param args menu arguments (items, theme, etc)
-- @param parent parent menu instance (for submenus)
-- @return menu instance
function menu.new(args, parent)
    if not args then
        return
    end

    for i = 1, #args.items do
        if not args.items[i] then
            table.remove(args.items, i)
        end
    end

    local theme = setmetatable(args.theme or {}, {
        __index = {
            placement_margin = dpi(3),
            bg = beautiful.bg,
            fg = beautiful.fg,
            border_color = beautiful.border_color_normal,
            border_width = beautiful.border_width,
            shape = shapes.rrect(10),
            margins = dpi(5),
            item_bg = beautiful.bg,
            item_fg = beautiful.fg,
            item_hover_bg = beautiful.ac,
            item_hover_border_color = beautiful.ac,
            item_hover_fg = beautiful.fg,
            item_width = dpi(150),
            item_height = dpi(25),
            item_shape = shapes.rrect_6,
            item_margins = { left = dpi(7), right = dpi(7) },
            item_spacing = dpi(2),
            item_font = beautiful.font,
        },
    })

    local ret = awful.popup({
        visible = false,
        ontop = true,
        type = "popup_menu",
        bg = "#00000000",
        placement = function()
            return { 0, 0 }
        end,
        widget = {
            widget = wibox.container.background,
            bg = theme.bg,
            fg = theme.fg,
            border_color = theme.border_color,
            border_width = theme.border_width,
            shape = theme.shape,
            {
                widget = wibox.container.margin,
                margins = theme.margins,
                {
                    id = "items-layout",
                    layout = wibox.layout.fixed.vertical,
                    spacing = theme.item_spacing,
                },
            },
        },
    })

    gtable.crush(ret, menu, true)
    local wp = ret._private

    wp.args = args.items
    wp.theme = theme
    wp.parent = parent
    wp.children = {}

    local items_layout = ret.widget:get_children_by_id("items-layout")[1]
    if wp.args then
        for index, item in ipairs(wp.args) do
            item.theme = theme
            items_layout:add(entry(ret, index, item))
        end
    end

    -- Setup centralized click-to-hide behavior
    click_to_hide.menu(ret, function()
        ret:get_root():hide()
    end, { outside_only = true, exclusive = true })

    return ret
end

--- Module entry point: returns a callable table for menu creation
return setmetatable({
    new = menu.new,
}, {
    __call = function(_, ...)
        return menu.new(...)
    end,
})
