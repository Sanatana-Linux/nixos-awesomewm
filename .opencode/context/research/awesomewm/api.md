# AwesomeWM API Reference

**Source**: Context7 MCP — /awesomewm/awesome
**Fetched**: 2026-07-01
**TTL**: 7 days

## Architecture

Awesome is a highly configurable window manager for X. Configured via Lua `rc.lua`. Core libraries:
- **awful** — window management (client, tag, screen, layout, placement, key, button, spawn)
- **wibox** — widget toolkit (widget, container, layout, drawable, wibar)
- **beautiful** — theming engine
- **gears** — utility library (object, timer, filesystem, shape, color, table, math)
- **naughty** — notifications
- **ruled** — client rules
- **menubar** — application menu

## Signal System

Configuration is event-driven and signal-based. Connect to signals emitted by screens, clients, and tags.

### Key Signals
- `request::desktop_decoration` — per-screen tag/wibar setup
- `request::wallpaper` — per-screen wallpaper
- `request::rules` — client rules registration
- `request::titlebars` — per-client titlebar setup
- `request::manage` — new client management

### Custom Signals (gears.object pattern)
```lua
local gobject = require("gears.object")
local obj = gobject({})
obj:emit_signal("my::signal", value)
obj:connect_signal("my::signal", function(_, value) end)
```

## Declarative Widget Construction

Widgets built from nested Lua tables with `widget` or `layout` key:

```lua
local mywidget = wibox.widget {
    {
        text   = "Hello World",
        widget = wibox.widget.textbox,
    },
    bg     = "#0055ff",
    fg     = "#ffffff",
    widget = wibox.container.background,
}
```

### Common Containers
- `wibox.container.background` — bg/fg color
- `wibox.container.margin` — spacing (left/right/top/bottom)
- `wibox.container.constraint` — size constraints (width/height/strategy)
- `wibox.container.tile` — tiled backgrounds

### Common Layouts
- `wibox.layout.fixed.horizontal/vertical` — fixed position
- `wibox.layout.flex.horizontal/vertical` — flexible distribution
- `wibox.layout.align.horizontal/vertical` — left/center/right alignment
- `wibox.layout.stack` — stacked layers

## Client Rules (ruled.client)

```lua
ruled.client.connect_signal("request::rules", function()
    ruled.client.append_rule {
        id         = "global",
        rule       = {},
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
        }
    }
    ruled.client.append_rule {
        id         = "floating",
        rule_any   = { class = { "Arandr", "Pavucontrol" } },
        properties = { floating = true }
    }
end)
```

## Tags (Workspaces)

```lua
screen.connect_signal("request::desktop_decoration", function(s)
    awful.tag({ "1", "2", "3" }, s, { layout1, layout2, layout3 })
end)

-- Navigation
awful.tag.viewnext()
awful.tag.viewprev()
awful.tag.history.restore()

-- Client-to-tag
client.focus:move_to_tag(tag)
client.focus:toggle_tag(tag)
```

## Titlebars

```lua
client.connect_signal("request::titlebars", function(c)
    awful.titlebar(c).widget = {
        { awful.titlebar.widget.iconwidget(c), layout = wibox.layout.fixed.horizontal },
        { awful.titlebar.widget.titlewidget(c), layout = wibox.layout.flex.horizontal },
        { awful.titlebar.widget.closebutton(c), layout = wibox.layout.fixed.horizontal },
        layout = wibox.layout.align.horizontal,
    }
end)
```

## Periodic Updates Pattern (gears.timer)

```lua
gears.timer {
    timeout   = 30,
    call_now  = true,
    autostart = true,
    callback  = function()
        awful.spawn.easy_async({ "sh", "-c", "command" }, function(out)
            widget.value = out
        end)
    end
}
```

## Wallpaper

```lua
screen.connect_signal("request::wallpaper", function(s)
    awful.wallpaper {
        screen = s,
        widget = {
            { image = beautiful.wallpaper, upscale = true, widget = wibox.widget.imagebox },
            valign = "center", halign = "center",
            widget = wibox.container.tile,
        }
    }
end)
```
