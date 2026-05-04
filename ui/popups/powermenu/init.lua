local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local gtable = require("gears.table")
local gfs = require("gears.filesystem")
local gcolor = require("gears.color")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local capi = { awesome = awesome, screen = screen }
local shapes = require("modules.shapes")
local click_to_hide = require("modules.click_to_hide")

local icons_dir = gfs.get_configuration_dir() .. "ui/popups/powermenu/icons/"

local powermenu = {}

local keys = {
    up = { "Up" },
    down = { "Down" },
    left = { "Left" },
    right = { "Right" },
    exec = { "Return" },
}

local function run_keygrabber(self)
    local wp = self._private
    wp.keygrabber = awful.keygrabber.run(function(_, key, event)
        if event ~= "press" then
            return
        end
        if key == "Escape" then
            self:hide()
        elseif gtable.hasitem(keys.up, key) then
            self:next()
            self:update_elements()
        elseif gtable.hasitem(keys.down, key) then
            self:back()
            self:update_elements()
        elseif gtable.hasitem(keys.left, key) then
            self:back()
            self:update_elements()
        elseif gtable.hasitem(keys.right, key) then
            self:next()
            self:update_elements()
        elseif gtable.hasitem(keys.exec, key) then
            wp.elements[wp.select_index].exec()
        end
    end)
end

function powermenu:next()
    local wp = self._private
    if wp.select_index ~= #wp.elements then
        wp.select_index = wp.select_index + 1
    else
        wp.select_index = 1
    end
end

function powermenu:back()
    local wp = self._private
    if wp.select_index ~= 1 then
        wp.select_index = wp.select_index - 1
    else
        wp.select_index = #wp.elements
    end
end

function powermenu:update_elements()
    local wp = self._private
    local elements_container =
        self.widget:get_children_by_id("elements-container")[1]
    elements_container:reset()

    for i, element in ipairs(wp.elements) do
        local element_widget = wibox.widget({
            widget = wibox.container.background,
            bg = beautiful.bg_gradient_button,
            border_width = dpi(1.5),
            border_color = "transparent",
            forced_width = dpi(108),
            forced_height = dpi(108),
            shape = shapes.rrect(8),
            buttons = {
                awful.button({}, 1, function()
                    if wp.select_index == i then
                        element.exec()
                    else
                        wp.select_index = i
                        self:update_elements()
                    end
                end),
            },
            {
                widget = wibox.container.margin,
                margins = dpi(15),
                {
                    widget = wibox.container.place,
                    halign = "center",
                    valign = "center",
                    {
                        widget = wibox.widget.imagebox,
                        image = gcolor.recolor_image(
                            element.icon,
                            beautiful.fg -- White icons like wibar buttons
                        ),
                        resize = true,
                        forced_width = dpi(48),
                        forced_height = dpi(48),
                        id = "icon_" .. i,
                    },
                },
            },
        })

        element_widget:connect_signal("mouse::enter", function(w)
            if element.name == "poweroff" then
                -- Special red gradient for poweroff button only
                local hover_gradient = "linear:0,0:0,32:0," .. beautiful.red .. ":1," .. "#b61442"
                w:set_bg(hover_gradient)
            else
                -- Standard wibar button hover effect for other buttons
                w:set_bg(beautiful.bg_gradient_recessed)
            end
            -- Keep icon white on hover like wibar buttons
            local icon_widget = w:get_children_by_id("icon_" .. i)[1]
            if icon_widget then
                icon_widget:set_image(
                    gcolor.recolor_image(element.icon, beautiful.fg)
                )
            end
        end)

        element_widget:connect_signal("mouse::leave", function(w)
            w:set_bg(beautiful.bg_gradient_button)
            -- Keep icon white like wibar buttons
            local icon_widget = w:get_children_by_id("icon_" .. i)[1]
            if icon_widget then
                icon_widget:set_image(
                    gcolor.recolor_image(element.icon, beautiful.fg)
                )
            end
        end)

        elements_container:add(element_widget)
    end
end

function powermenu:show()
    local wp = self._private
    if wp.shown then
        return
    end
    wp.shown = true
    self.visible = true
    self:emit_signal("property::shown", wp.shown)
    wp.select_index = 1
    self:update_elements()
    run_keygrabber(self)
end

function powermenu:hide()
    local wp = self._private
    if not wp.shown then
        return
    end
    wp.shown = false
    if wp.keygrabber then
        awful.keygrabber.stop(wp.keygrabber)
        wp.keygrabber = nil
    end
    wp.select_index = 1
    self.visible = false
    self:emit_signal("property::shown", wp.shown)
end

function powermenu:toggle()
    if not self.visible then
        self:show()
    else
        self:hide()
    end
end

local function new()
    local ret = awful.popup({
        visible = false,
        ontop = true,
        type = "tooltip",
        screen = capi.screen.primary,
        bg = "#00000000",
        name = "awesome-popup",
        placement = awful.placement.centered,
        widget = {
            widget = wibox.container.background,
            bg = beautiful.bg .. "99",
            border_width = dpi(1.15),
            border_color = beautiful.fg_alt,
            shape = shapes.rrect_25,
            {
                widget = wibox.container.margin,
                margins = dpi(12),
                {
                    id = "elements-container",
                    spacing = dpi(12),
                    layout = wibox.layout.fixed.horizontal,
                },
            },
        },
    })

    gtable.crush(ret, powermenu, true)
    local wp = ret._private

    wp.elements = {
        {
            exec = function()
                awful.spawn("/home/tlh/.config/awesome/bin/glitchlock.sh")
                ret:hide()
            end,
            icon = icons_dir .. "lock.svg",
            name = "lock",
        },
        {
            exec = function()
                awful.spawn("poweroff")
            end,
            icon = icons_dir .. "poweroff.svg",
            name = "poweroff", -- Special name for red hover effect
        },
        {
            exec = function()
                awful.spawn("reboot")
            end,
            icon = icons_dir .. "reboot.svg",
            name = "reboot",
        },
        {
            exec = function()
                capi.awesome.quit()
            end,
            icon = icons_dir .. "exit.svg",
            name = "exit",
        },
    }

    -- Setup centralized click-to-hide behavior
    click_to_hide.popup(ret, function()
        ret:hide()
    end, { outside_only = true, exclusive = true })

    return ret
end

local instance = nil
local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return {
    get_default = get_default,
}
