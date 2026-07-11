---
name: awesome-popup
description:
  Create AwesomeWM popup components with this codebase's singleton, gobject, and
  OSD patterns. Use when adding a popup, wiring mutual-exclusion, or
  implementing control panel applets.
---

# AwesomeWM Popup Patterns

This skill encodes the exact patterns used for popup UI components in this
AwesomeWM configuration. All popups follow the **singleton + gobject + gtable.crush**
pattern with `_private` state, mutual-exclusion signal wiring in `ui/init.lua`,
and centralized click-to-hide via `click_to_hide.popup()`.

## When to Use

- Adding a new popup (directory + `init.lua` + registration in `ui/init.lua`)
- Modifying show/hide/toggle logic on an existing popup
- Wiring mutual-exclusion signals between popups
- Creating a control panel applet (button.lua + page.lua submodule pattern)
- Creating an on-screen-display popup (volume, brightness, etc.)
- Adding click-to-hide or Escape-to-dismiss behavior
- Reviewing or refactoring an existing popup

## File Structure

```
ui/popups/{name}/
├── init.lua          # Popup singleton (required)
├── submodule.lua     # Optional submodule for complex popups
└── icons/            # Optional SVG icons directory

# Control panel applets (submodules of control_panel):
ui/popups/control_panel/{applet_name}/
├── init.lua          # Applet widget (instantiable, not singleton)
├── button.lua        # Toggle/reveal button for control panel
└── page.lua          # Full-page view (for applets with drill-down)
```

## Popup Singleton Pattern

Every popup is a **singleton** — exactly one instance created lazily via
`get_default()`. The pattern mirrors service singletons.

### Template

```lua
---@diagnostic disable: undefined-global
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local dpi = beautiful.xresources.apply_dpi
local capi = { screen = screen }
local shapes = require("modules.shapes")
local anim = require("modules.animations")
local click_to_hide = require("modules.click_to_hide")

-- Module table — functions are crushed onto the popup object
local my_popup = {}

-- ── show ──────────────────────────────────────────────────────────
function my_popup:show()
    local wp = self._private
    if wp.shown then return end
    wp.shown = true

    -- Optional: trigger data refresh before showing
    -- wp.some_service:get_data()

    self.opacity = 0
    self.visible = true

    gtimer.delayed_call(function()
        local placement_func = self.placement
        if placement_func then placement_func(self) end

        gtimer.delayed_call(function()
            self:emit_signal("widget::layout_changed")

            -- Slide-up animation
            local final_y = self.y
            local start_y = final_y + dpi(20)
            self.y = start_y

            anim.animate({
                start = 0,
                target = 1,
                duration = 0.3,
                easing = anim.easing.quadratic,
                update = function(progress)
                    self.opacity = progress
                    self.y = start_y + (final_y - start_y) * progress
                end,
                complete = function()
                    self:emit_signal("property::shown", wp.shown)
                end,
            })
        end)
    end)
end

-- ── hide ──────────────────────────────────────────────────────────
function my_popup:hide()
    local wp = self._private
    if not wp.shown then return end
    wp.shown = false

    local start_y = self.y
    local final_y = start_y + dpi(20)

    anim.animate({
        start = 1,
        target = 0,
        duration = 0.2,
        easing = anim.easing.quadratic,
        update = function(progress)
            self.opacity = progress
            self.y = start_y + (final_y - start_y) * (1 - progress)
        end,
        complete = function()
            self.visible = false
            self:emit_signal("property::shown", wp.shown)
        end,
    })
end

-- ── toggle ────────────────────────────────────────────────────────
function my_popup:toggle()
    if not self.visible then self:show() else self:hide() end
end

-- ── constructor ───────────────────────────────────────────────────
local function new()
    local ret = awful.popup({
        visible = false,
        ontop = true,
        screen = capi.screen.primary,
        bg = "#00000000",                    -- Transparent popup base
        name = "awesome-popup",
        placement = function(c)
            awful.placement.bottom_right(c, {
                honor_workarea = true,
                margins = {
                    bottom = beautiful.useless_gap or 0,
                    right = beautiful.useless_gap or 0,
                },
            })
        end,
        widget = {
            widget = wibox.container.background,
            bg = beautiful.bg .. "99",       -- Semi-transparent content bg
            border_width = beautiful.border_width,
            border_color = beautiful.border_color_normal,
            shape = shapes.rrect(20),
            {
                widget = wibox.container.margin,
                margins = dpi(12),
                {
                    id = "main-layout",
                    layout = wibox.layout.fixed.vertical,
                    spacing = dpi(6),
                    -- Your content here
                },
            },
        },
    })

    -- Crush module methods onto the popup object
    gtable.crush(ret, my_popup, true)
    local wp = ret._private
    wp.shown = false

    -- Setup centralized click-to-hide
    click_to_hide.popup(ret, function()
        ret:hide()
    end, { outside_only = true, exclusive = true })

    return ret
end

-- ── singleton ─────────────────────────────────────────────────────
local instance = nil
local function get_default()
    if not instance then instance = new() end
    return instance
end

return { get_default = get_default }
```

### Key Elements

| Element | Purpose |
|---------|---------|
| `gtable.crush(ret, module, true)` | Copies all module functions onto the popup object |
| `ret._private` | Private state table accessed via `local wp = self._private` |
| `wp.shown` | Guard flag — prevents double-show/double-hide |
| `bg = "#00000000"` | Transparent popup base; actual bg on inner widget with alpha |
| `self:emit_signal("property::shown", wp.shown)` | Emitted after animation completes (NOT immediately) |
| `click_to_hide.popup(...)` | Centralized click-outside-to-dismiss + Escape key |
| `name = "awesome-popup"` | Required for click_to_hide to match popup windows |
| `placement` function | Repositions popup relative to screen edges |

## Guard on Shown

Both `show()` and `hide()` **must** check `wp.shown` first to prevent
double-trigger and animation conflicts:

```lua
function popup:show()
    local wp = self._private
    if wp.shown then return end   -- ← GUARD
    wp.shown = true
    -- ... animation ...
end

function popup:hide()
    local wp = self._private
    if not wp.shown then return end  -- ← GUARD
    wp.shown = false
    -- ... animation ...
end
```

Good reasons to skip the guard (rare):
- **OSD popups** — `show()` is called many times in rapid succession
  (volume changes), and they auto-hide via timer. Example:
  `on_screen_display/volume/init.lua`.

## Registration in ui/init.lua

1. **Require** the popup singleton at the top of `ui/init.lua`:
   ```lua
   local my_popup = require("ui.popups.my_popup").get_default()
   ```

2. **Wire mutual-exclusion** — connect `property::shown` signals so only one
   popup is visible at a time:
   ```lua
   my_popup:connect_signal("property::shown", function(_, shown)
       if shown then
           powermenu:hide()
           launcher:hide()
           menu:hide()
           screenshot_popup:hide()
           control_panel:hide()
       end
   end)
   ```

3. **Add to global click-away** — insert `my_popup:hide()` into the
   `click_hideaway()` function:
   ```lua
   local function click_hideaway()
       menu:hide()
       launcher:hide()
       powermenu:hide()
       control_panel:hide()
       screenshot_popup:hide()
       day_info_panel:hide()
       battery:hide()
       my_popup:hide()         -- ← add here
   end
   ```

## Mutual-Exclusion Wiring

The current mutual-exclusion chain in `ui/init.lua` (lines 105-137):

```
powermenu shows  → hides: launcher, control_panel, menu, screenshot_popup
launcher shows   → hides: powermenu, menu, screenshot_popup
control_panel shows → hides: powermenu, menu, screenshot_popup
screenshot_popup shows → hides: powermenu, menu, launcher, control_panel
```

The general rule: **when any popup shows, all other popups hide.** The exact
wiring depends on which popups can overlap. Use the pattern:

```lua
my_popup:connect_signal("property::shown", function(_, shown)
    if shown == true then
        other_popup:hide()
        another_popup:hide()
    end
end)
```

Also ensure existing popups hide the new one:

```lua
powermenu:connect_signal("property::shown", function(_, shown)
    if shown == true then
        launcher:hide()
        control_panel:hide()
        menu:hide()
        screenshot_popup:hide()
        my_popup:hide()     -- ← add here
    end
end)
```

## Placement Options

### bottom_right (most common — control_panel, battery)

```lua
placement = function(c)
    awful.placement.bottom_right(c, {
        honor_workarea = true,
        margins = {
            bottom = (c.screen.bar and c.screen.bar.height or 0)
                + (beautiful.useless_gap or 0),
            right = beautiful.useless_gap or 0,
        },
    })
end
```

### bottom_left (launcher)

```lua
placement = function(c)
    awful.placement.bottom_left(c, {
        honor_workarea = true,
        margins = {
            bottom = (c.screen.bar and c.screen.bar.height or 0)
                + (beautiful.useless_gap or 0),
            left = beautiful.useless_gap or 0,
        },
    })
end
```

### centered (powermenu)

```lua
placement = awful.placement.centered,
```

## OSD Popup Pattern

On-screen-display popups (volume, brightness, layouts) use a lighter-weight
pattern — no animation, no backdrop, auto-hide timer. Located in
`ui/popups/on_screen_display/`.

### Template

```lua
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local dpi = beautiful.xresources.apply_dpi

local osd = {}

-- ── show ──────────────────────────────────────────────────────────
function osd:show(value)
    local wp = self._private
    local icon_w = self.widget:get_children_by_id("icon")[1]
    local text_w = self.widget:get_children_by_id("text")[1]
    local bar_w = self.widget:get_children_by_id("progressbar")[1]

    -- Update icon based on value
    icon_w.text = choose_icon(value)

    -- Update label
    text_w.text = tostring(value)

    -- Animate progressbar
    local anim = require("modules.animations")
    anim.animate({
        start = bar_w.value,
        target = value,
        duration = 0.3,
        easing = anim.easing.linear,
        update = function(p) bar_w.value = p end,
    })

    -- Show & (re)start auto-hide timer
    if not self.visible then
        self.visible = true
        wp.timer:start()
    else
        wp.timer:again()
    end
end

-- ── hide ──────────────────────────────────────────────────────────
function osd:hide()
    self.visible = false
    local wp = self._private
    wp.timer:stop()
end

local function new()
    local ret = awful.popup({
        visible = false,
        ontop = true,
        minimum_height = dpi(60),
        maximum_height = dpi(60),
        minimum_width = dpi(290),
        maximum_width = dpi(290),
        placement = function(d)
            awful.placement.bottom(d, {
                margins = { bottom = dpi(20) },
                honor_workarea = true,
            })
        end,
        widget = {
            widget = wibox.container.margin,
            margins = dpi(20),
            {
                layout = wibox.layout.fixed.horizontal,
                fill_space = true,
                spacing = dpi(8),
                {
                    widget = wibox.widget.textbox,
                    id = "icon",
                    font = beautiful.font_name .. " 14",
                },
                {
                    widget = wibox.container.background,
                    forced_width = dpi(36),
                    {
                        widget = wibox.widget.textbox,
                        id = "text",
                        halign = "center",
                    },
                },
                {
                    widget = wibox.widget.progressbar,
                    id = "progressbar",
                    max_value = 100,
                    forced_width = dpi(380),
                    forced_height = dpi(10),
                    background_color = beautiful.bg_normal,
                    color = beautiful.fg,
                },
            },
        },
    })

    gtable.crush(ret, osd, true)
    local wp = ret._private

    -- Auto-hide after 4 seconds
    wp.timer = gtimer({
        timeout = 4,
        autostart = false,
        callback = function() ret:hide() end,
    })

    return ret
end

local instance = nil
function osd.get_default()
    if not instance then instance = new() end
    return instance
end

return osd
```

### OSD Key Differences from Standard Popups

| Aspect | Standard Popup | OSD |
|--------|---------------|-----|
| Show guard | `wp.shown` double-check | None — called repeatedly |
| Animation | Slide-up fade-in (0.3s) | Progressbar animation only (0.3s) |
| Hide trigger | Explicit call or click-away | Auto-hide timer (4s) |
| `property::shown` signal | Emitted after animation | Not emitted |
| `click_to_hide` | Yes | No |
| Placement | bottom_right / bottom_left | bottom centered |

### Connecting OSD to Services

OSDs connect to service signals for automatic display:

```lua
-- In bar module or keybind handler:
local osd_volume = require("ui.popups.on_screen_display.volume").get_default()

-- Connect to audio service
local audio = require("service.audio").get_default()
audio:connect_signal("default-sink::volume", function(_, value, is_muted)
    osd_volume:show(value, is_muted)
end)
```

## Control Panel Integration

If a popup belongs in the **control panel** (`ui/popups/control_panel/`), it
follows the applet pattern with button/page/init submodules.

### Applet Structure

```
ui/popups/control_panel/{applet_name}/
├── init.lua      # Main applet widget (instantiable, returns wibox.widget)
├── button.lua    # Toggle/reveal button in control panel header
└── page.lua      # Full-page drill-down view (for complex applets)
```

### init.lua Pattern (instantiable widget)

Unlike popups, applet widgets are **not** singletons — they return a
callable module that creates widget instances:

```lua
local function new()
    local ret = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg_alt .. "aa",
        shape = shapes.rrect(10),
        -- ... content with id'd children ...
    })

    -- Connect to services via signal wiring
    local service = require("service.some_service").get_default()
    service:connect_signal("property::value", function(_, val)
        local child = ret:get_children_by_id("some-id")[1]
        child:set_markup(tostring(val))
    end)

    return ret
end

return setmetatable({
    new = new,
}, {
    __call = function(_, ...) return new(...) end,
})
```

### button.lua Pattern

Buttons connect to **service signals** to update their state display:

```lua
local wibox = require("wibox")
local beautiful = require("beautiful")
local service = require("service.some_service").get_default()

local function new()
    local ret = wibox.widget({
        widget = wibox.container.background,
        -- ... button with id="reveal-button" ...
    })

    -- Connect to service signals to update state
    service:connect_signal("property::state", function(_, state)
        local btn = ret:get_children_by_id("reveal-button")[1]
        -- Update button appearance based on state
    end)

    return ret
end

return setmetatable({ new = new }, { __call = function(_, ...) return new(...) end })
```

The control panel's `init.lua` wires button clicks to page navigation:

```lua
-- In control_panel init.lua:
wp.network_button:get_children_by_id("reveal-button")[1]:buttons({
    awful.button({}, 1, function() ret:setup_network_page() end),
})
```

### page.lua Pattern

Pages are full-view replacements for the control panel's `main-layout`:

```lua
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local function new()
    return wibox.widget({
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(6),
        -- ... page content ...
        -- Must include a close button with id="bottombar-close-button":
        {
            id = "bottombar-close-button",
            widget = wibox.widget.textbox,
            -- ... styled as a back/close button ...
        },
    })
end

return setmetatable({ new = new }, { __call = function(_, ...) return new(...) end })
```

### Registration in control_panel/init.lua

```lua
-- 1. Require
local my_applet = require("ui.popups.control_panel.my_applet")
local my_button = require("ui.popups.control_panel.my_applet.button")
local my_page = require("ui.popups.control_panel.my_applet.page")

-- 2. In constructor:
wp.my_applet = my_applet()
wp.my_button = my_button()
wp.my_page = my_page()

-- 3. Wire button to page
wp.my_button:get_children_by_id("reveal-button")[1]:buttons({
    awful.button({}, 1, function() ret:setup_my_page() end),
})

-- 4. Wire page close button back to main
wp.my_page:get_children_by_id("bottombar-close-button")[1]:buttons({
    awful.button({}, 1, function() ret:setup_main_page() end),
})

-- 5. Add navigation methods
function control_panel:setup_my_page()
    local wp = self._private
    local main_layout = self.widget:get_children_by_id("main-layout")[1]
    main_layout:reset()
    main_layout:add(wp.my_page)
end
```

## Signal Wiring Convention

### Popup-to-Service Wiring

Popups connect to services using `entity::event` signal convention:

| Service | Signal | Usage |
|---------|--------|-------|
| `service.audio` | `default-sink::volume` | Volume changed |
| `service.audio` | `default-sink::mute` | Mute toggled |
| `service.audio` | `default-source::volume` | Mic volume changed |
| `service.audio` | `default-source::mute` | Mic mute toggled |
| `service.battery` | `property::level` | Battery level changed |
| `service.battery` | `property::is_charging` | Charging state changed |
| `service.system_info` | `property::cpu_usage` | CPU usage updated |

General pattern:
```lua
local svc = require("service.some_service").get_default()
svc:connect_signal("entity::event", function(_, value)
    -- Update widget
end)
```

### Efficiency: Only Update When Visible

For data-heavy popups, gate updates so they only refresh when the popup is
visible:

```lua
svc:connect_signal("property::value", function()
    if wp.shown then
        self:_update_display()
    end
end)
```

### Live Update Timer

For popups that show live data (system monitor, clock), use a repeating
timer that only fires while visible:

```lua
wp.update_timer = gtimer({
    timeout = 2,  -- seconds
    autostart = false,
    callback = function()
        if wp.shown then self:_refresh_data() end
    end,
})

function popup:show()
    -- ...
    wp.update_timer:start()
end

function popup:hide()
    wp.update_timer:stop()
    -- ...
end
```

## click_to_hide Integration

The `click_to_hide.popup()` function (from `modules.click_to_hide`) provides:
- Click-outside-to-dismiss
- Escape key dismissal
- Exclusive mode (auto-hides other registered popups)

```lua
click_to_hide.popup(ret, function()
    ret:hide()
end, {
    outside_only = true,   -- Only hide on outside clicks (not inside)
    exclusive = true,      -- Auto-hide other click_to_hide popups
    enable_escape = true,  -- Escape key dismisses (default: true)
    popup_name = "awesome-popup",  -- Window name for matching (default)
})
```

Typically called once in the popup constructor after `gtable.crush`.

## Animation Pattern

All animated popups use `modules.animations` with quadratic easing:

```lua
local anim = require("modules.animations")

-- Show animation (fade in + slide up)
anim.animate({
    start = 0,
    target = 1,
    duration = 0.3,
    easing = anim.easing.quadratic,
    update = function(progress)
        self.opacity = progress
        self.y = start_y + (final_y - start_y) * progress
    end,
    complete = function()
        self:emit_signal("property::shown", wp.shown)
    end,
})
```

- **Show**: 0.3s duration, opacity 0→1, slide up 20dp
- **Hide**: 0.2s duration, opacity 1→0, slide down 20dp
- **Easing**: `anim.easing.quadratic` for natural feel

## Common Patterns Reference

### Widget Construction with `id` for Access

```lua
{
    id = "my-widget",
    widget = wibox.widget.textbox,
    -- ...
}
-- Access via:
local w = container:get_children_by_id("my-widget")[1]
```

### Semi-Transparent Background

```lua
bg = beautiful.bg .. "99",   -- ~60% opacity
bg = beautiful.bg .. "bb",   -- ~73% opacity
bg = beautiful.bg .. "55",   -- ~33% opacity
```

### Using `dpi()` for All Dimensions

```lua
local dpi = beautiful.xresources.apply_dpi
-- All pixel values go through dpi():
forced_width = dpi(120),
margins = dpi(12),
border_width = dpi(1.15),
```

### Registering Button Press Handlers

```lua
buttons = {
    awful.button({}, 1, function()
        -- Left-click action
    end),
    awful.button({}, 3, function()
        -- Right-click action
    end),
}
```

## Adding a New Popup — Complete Checklist

- [ ] Create `ui/popups/{name}/init.lua` with singleton pattern
- [ ] Use `gtable.crush(ret, module, true)` in constructor
- [ ] Initialize `wp.shown = false`
- [ ] Implement `show()` with guard, animation, `property::shown` signal
- [ ] Implement `hide()` with guard, animation, `property::shown` signal
- [ ] Implement `toggle()`
- [ ] Set `bg = "#00000000"` on popup, alpha bg on inner widget
- [ ] Set `name = "awesome-popup"` for click_to_hide matching
- [ ] Call `click_to_hide.popup(ret, hide_fn, options)` in constructor
- [ ] Export `{ get_default = get_default }`
- [ ] Require in `ui/init.lua`: `local x = require("ui.popups.x").get_default()`
- [ ] Wire mutual-exclusion: `x:connect_signal("property::shown", ...)`
- [ ] Add `x:hide()` to `click_hideaway()` function
- [ ] Add keybinding in `core/keybind/` to invoke `x:toggle()`
- [ ] Test with `./bin/awmtt-ng.sh restart`

## Anti-Patterns — What NOT to Do

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Creating a popup without `gtable.crush` | Methods won't be on the object; `self` won't work |
| Skipping the `wp.shown` guard | Animation conflicts, double-show bugs |
| Emitting `property::shown` before animation completes | Other popups hide during the show animation |
| Using `#RRGGBB` (no alpha) on `popup` bg | Should be `"#00000000"` (transparent) |
| Not calling `click_to_hide.popup()` | No click-away, Escape doesn't work |
| Forgetting mutual-exclusion wiring in `ui/init.lua` | Popups stack on top of each other |
| Creating a new popup without adding to `click_hideaway()` | Click outside won't hide it |
| Using `os.execute()` or `io.popen()` in popup | Use `awful.spawn()` instead |
| Writing global variables | Always use `local` + `capi` table for AwesomeWM globals |
