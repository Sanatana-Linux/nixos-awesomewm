local awful = require("awful")
local tagswitch = require("mods.tagswitch")

modkey = "Mod4"

awful.keyboard.append_global_keybindings({
    awful.key(
        { modkey },
        "Left",
        awful.tag.viewprev,
        { description = "view previous", group = "tag" }
    ),
    awful.key(
        { modkey },
        "Right",
        awful.tag.viewnext,
        { description = "view next", group = "tag" }
    ),
    awful.key(
        { modkey },
        "Escape",
        awful.tag.history.restore,
        { description = "go back", group = "tag" }
    ),
    awful.key({
        modifiers = { modkey },
        keygroup = "numrow",
        description = "only view tag",
        group = "tag",
        on_press = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
            if tagswitch then
                local t = awful.screen.focused().selected_tag
                tagswitch.animate(tostring(t.index))
            end
            collectgarbage("collect")
        end,
    }),
    awful.key({
        modifiers = { modkey, "Control" },
        keygroup = "numrow",
        description = "toggle tag",
        group = "tag",
        on_press = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    }),
    awful.key({
        modifiers = { modkey, "Shift" },
        keygroup = "numrow",
        description = "only view tag",
        group = "tag",
        on_press = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    }),
    awful.key({
        modifiers = { modkey, "Control", "Shift" },
        keygroup = "numrow",
        description = "toggle focused client on tag",
        group = "tag",
        on_press = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
    }),
    awful.key({
        modifiers = { modkey },
        keygroup = "numpad",
        description = "select layout directly",
        group = "layout",
        on_press = function(index)
            local t = awful.screen.focused().selected_tag
            if t then
                t.layout = t.layouts[index] or t.layout
            end
        end,
    }),
})
