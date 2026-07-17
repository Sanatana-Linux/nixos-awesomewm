---@diagnostic disable: undefined-global
--- Custom layoutbox constructor.
-- Creates the inner layoutbox widget (imagebox + textbox + tooltip + DPI margins)
-- that the wibar layoutbox module wraps with themed styling and click handlers.
-- Designed as a drop-in replacement for `awful.widget.layoutbox` internals.
--
-- Hybrid of NixOS stock (`awesome-git-2024-12-08`) + custom improvements:
-- DPI-aware margins, explicit widget constructors with stored references,
-- nil-safe screen access, and tooltip retained.

local capi = { screen = screen, tag = tag }
local layout = require("awful.layout")
local tooltip = require("awful.tooltip")
local beautiful = require("beautiful")
local wibox = require("wibox")
local dpi = beautiful.xresources.apply_dpi

local function get_screen(s)
    return s and capi.screen[s]
end

local boxes = nil

local function update(w, screen)
    screen = get_screen(screen)
    local name = layout.getname(layout.get(screen))
    w._layoutbox_tooltip:set_text(name or "[no name]")

    local image_name = "layout_" .. name
    local theme_image = beautiful[image_name]
    local success = false
    if theme_image ~= nil then
        success = w.imagebox:set_image(beautiful[image_name])
    end
    w.textbox.text = success and "" or name
end

local function update_from_tag(t)
    local screen = get_screen(t.screen)
    local w = boxes and boxes[screen]
    if w then
        update(w, screen)
    end
end

--- Create a layoutbox composite widget for the given screen.
-- @tparam screen s Screen to create the layoutbox for
-- @treturn widget Layoutbox composite (imagebox + textbox + tooltip)
return function(s)
    local screen = get_screen(s or 1)

    -- Register signal handlers once
    if boxes == nil then
        boxes = setmetatable({}, { __mode = "kv" })
        capi.tag.connect_signal("property::selected", update_from_tag)
        capi.tag.connect_signal("property::layout", update_from_tag)
        capi.tag.connect_signal("property::screen", function()
            for s, w in pairs(boxes) do
                if s.valid then
                    update(w, s)
                end
            end
        end)
    end

    -- Reuse existing layoutbox for this screen if one exists
    local w = boxes[screen]
    if not w then
        local imagebox = wibox.widget.imagebox()
        local textbox = wibox.widget.textbox()

        w = wibox.widget({
            {
                widget = wibox.container.margin,
                margins = dpi(4),
                imagebox,
            },
            textbox,
            layout = wibox.layout.fixed.horizontal,
        })

        w.imagebox = imagebox
        w.textbox = textbox
        w._layoutbox_tooltip = tooltip({ objects = { w }, delay_show = 1 })

        update(w, screen)
        boxes[screen] = w
    end

    return w
end
