# Hover-Reveal Wibar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the wibar to a hover-revealed, animated bar that slides in from the bottom when the mouse hovers near the screen edge, displays on top of windows without affecting their geometry.

**Architecture:** Replace `awful.wibar` with a custom `wibox` that uses `ontop = true` and no struts. A separate invisible trigger zone wibox at the bottom edge detects mouse hover. Animation uses the existing `modules.animations` module for smooth slide effects.

**Tech Stack:** AwesomeWM wibox API, gears.timer, modules.animations

---

## File Structure

| File | Action | Purpose |
|------|--------|---------|
| `ui/bar/hover_bar.lua` | Create | New module for hover-reveal bar logic |
| `ui/bar/init.lua` | Modify | Replace awful.wibar with hover_bar module |
| `ui/init.lua` | Modify | Update bar setup for new hover behavior |

---

### Task 1: Create hover_bar module

**Files:**
- Create: `ui/bar/hover_bar.lua`

- [ ] **Step 1: Create the hover_bar module skeleton**

Create `ui/bar/hover_bar.lua` with the module structure:

```lua
-- ui/bar/hover_bar.lua
-- Hover-reveal wibar that slides in from bottom when mouse approaches screen edge.

local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local anim = require("modules.animation")
local gtimer = require("gears.timer")

local hover_bar = {}

-- Configuration constants
local TRIGGER_ZONE_HEIGHT = dpi(3)
local HIDE_DELAY_SECONDS = 3
local ANIMATION_DURATION = 0.25
local BAR_HEIGHT_PRIMARY = dpi(30)
local BAR_HEIGHT_SECONDARY = dpi(40)

function hover_bar.create(args)
    local screen = args.screen
    local bar_height = args.height or BAR_HEIGHT_PRIMARY
    local bar_widget = args.widget
    local is_primary = args.is_primary or false

    local screen_geo = screen.geometry
    local hidden_y = screen_geo.y + screen_geo.height
    local visible_y = screen_geo.y + screen_geo.height - bar_height

    -- State tracking
    local state = {
        is_visible = false,
        is_animating = false,
        hide_timer = nil,
    }

    -- Create the trigger zone (invisible, at bottom of screen)
    local trigger_zone = wibox({
        x = screen_geo.x,
        y = screen_geo.y + screen_geo.height - TRIGGER_ZONE_HEIGHT,
        width = screen_geo.width,
        height = TRIGGER_ZONE_HEIGHT,
        visible = true,
        ontop = false,
        type = "utility",
        bg = "#00000000",
        input_pass_through = false,
    })

    -- Create the bar wibox
    local bar = wibox({
        x = screen_geo.x,
        y = hidden_y,
        width = screen_geo.width,
        height = bar_height,
        visible = true,
        ontop = true,
        type = "utility",
        bg = beautiful.bg .. "99",
        border_width = 0,
        border_color = beautiful.bg .. "66",
        widget = bar_widget,
    })

    -- Clear any struts (ensure no geometry impact)
    bar:struts({ left = 0, right = 0, top = 0, bottom = 0 })

    -- Animation controller reference
    local animation_controller = nil

    -- Helper: cancel hide timer
    local function cancel_hide_timer()
        if state.hide_timer then
            state.hide_timer:stop()
            state.hide_timer = nil
        end
    end

    -- Helper: start hide timer
    local function start_hide_timer()
        cancel_hide_timer()
        state.hide_timer = gtimer({
            timeout = HIDE_DELAY_SECONDS,
            autostart = true,
            single_shot = true,
            callback = function()
                if state.is_visible and not state.is_animating then
                    hover_bar.hide(bar, state, screen_geo, bar_height, animation_controller)
                end
            end,
        })
    end

    -- Helper: animate to position
    local function animate_to(target_y, callback)
        if animation_controller then
            animation_controller.stop()
        end
        state.is_animating = true
        animation_controller = anim.slide_y(bar, {
            start = bar.y,
            target = target_y,
            duration = ANIMATION_DURATION,
            easing = anim.easing.quadratic,
            update = function(pos)
                bar.y = pos
            end,
            complete = function()
                state.is_animating = false
                if callback then
                    callback()
                end
            end,
        })
    end

    -- Trigger zone mouse enter: show bar
    trigger_zone:connect_signal("mouse::enter", function()
        cancel_hide_timer()
        if not state.is_visible then
            state.is_visible = true
            animate_to(visible_y)
        end
    end)

    -- Trigger zone mouse leave: start hide timer
    trigger_zone:connect_signal("mouse::leave", function()
        start_hide_timer()
    end)

    -- Bar mouse enter: cancel hide timer
    bar:connect_signal("mouse::enter", function()
        cancel_hide_timer()
    end)

    -- Bar mouse leave: start hide timer
    bar:connect_signal("mouse::leave", function()
        start_hide_timer()
    end)

    -- Handle screen geometry changes
    screen:connect_signal("property::geometry", function()
        local geo = screen.geometry
        local new_hidden_y = geo.y + geo.height
        local new_visible_y = geo.y + geo.height - bar_height

        trigger_zone.x = geo.x
        trigger_zone.y = geo.y + geo.height - TRIGGER_ZONE_HEIGHT
        trigger_zone.width = geo.width

        bar.x = geo.x
        bar.width = geo.width
        if state.is_visible then
            bar.y = new_visible_y
        else
            bar.y = new_hidden_y
        end
    end)

    return {
        bar = bar,
        trigger_zone = trigger_zone,
        show = function()
            cancel_hide_timer()
            if not state.is_visible then
                state.is_visible = true
                animate_to(visible_y)
            end
        end,
        hide = function()
            cancel_hide_timer()
            if state.is_visible then
                hover_bar.hide(bar, state, screen_geo, bar_height, animation_controller)
            end
        end,
        destroy = function()
            cancel_hide_timer()
            if animation_controller then
                animation_controller.stop()
            end
            bar:destroy()
            trigger_zone:destroy()
        end,
    }
end

function hover_bar.hide(bar, state, screen_geo, bar_height, animation_controller)
    local hidden_y = screen_geo.y + screen_geo.height
    if animation_controller then
        animation_controller.stop()
    end
    state.is_animating = true
    animation_controller = anim.slide_y(bar, {
        start = bar.y,
        target = hidden_y,
        duration = ANIMATION_DURATION,
        easing = anim.easing.quadratic,
        update = function(pos)
            bar.y = pos
        end,
        complete = function()
            state.is_animating = false
            state.is_visible = false
        end,
    })
end

return hover_bar
```

- [ ] **Step 2: Validate syntax**

Run: `awesome -c /home/tlh/.config/awesome/rc.lua --check`

Expected: No syntax errors.

- [ ] **Step 3: Commit**

```bash
git add ui/bar/hover_bar.lua
git commit -m "feat: add hover_bar module for hover-reveal wibar"
```

---

### Task 2: Modify bar/init.lua to use hover_bar

**Files:**
- Modify: `ui/bar/init.lua`

- [ ] **Step 1: Update bar/init.lua**

Replace the contents of `ui/bar/init.lua`:

```lua
-- ui/bar/init.lua
-- This module defines and assembles the main status bar (wibar) for AwesomeWM.
-- Hover-reveal bar that slides in from bottom on mouse hover.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local menu = require("ui.popups.menu").get_default()
local hover_bar = require("ui.bar.hover_bar")

-- Load wibar component modules
local launcher_button = require("ui.bar.modules.launcher_button")
local control_panel_button = require("ui.bar.modules.control_panel_button")
local time_widget = require("ui.bar.modules.time_widget")
local tray_widget = require("ui.bar.modules.tray_widget")
local layoutbox_widget = require("ui.bar.modules.layoutbox_widget")
local new_tags_widget = require("ui.bar.modules.taglist_and_tasklist_buttons")
local battery_widget = require("ui.bar.modules.battery")

local bar = {}

-- Define button configurations once to be reused
local taglist_buttons = awful.util.table.join(
    awful.button({}, 1, function(t)
        t:view_only()
    end),
    awful.button({ "Mod4" }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ "Mod4" }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end)
)

-- Define the correct behavior for tasklist (client icon) clicks
local tasklist_buttons = awful.util.table.join(
    awful.button({}, 1, function(c)
        awful.client.jumpto(c)
    end),
    awful.button({}, 3, function(c)
        menu:toggle_client_menu(c)
    end)
)

-- Creates the wibar for the primary screen.
function bar.create_primary(s)
    local bar_widget = {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            widget = wibox.container.margin,
            margins = {
                top = dpi(2),
                bottom = dpi(2),
                left = dpi(7),
                right = dpi(7),
            },
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(8),
                launcher_button(),
            },
        },
        { -- Center widgets
            widget = wibox.container.margin,
            margins = {
                top = dpi(2),
                bottom = dpi(2),
                left = dpi(7),
                right = dpi(7),
            },
            new_tags_widget.new({
                screen = s,
                taglist_buttons = taglist_buttons,
                tasklist_buttons = tasklist_buttons,
            }),
        },
        { -- Right widgets
            widget = wibox.container.margin,
            margins = {
                top = dpi(2),
                bottom = dpi(2),
                left = 0,
                right = dpi(7),
            },
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(8),
                tray_widget(),
                layoutbox_widget(s),
                battery_widget(),
                time_widget(),
                control_panel_button(),
            },
        },
    }

    local hb = hover_bar.create({
        screen = s,
        height = dpi(30),
        widget = bar_widget,
        is_primary = true,
    })

    return hb
end

-- Wibar for secondary screens.
function bar.create_secondary(s)
    local tags_widget = new_tags_widget.new({
        screen = s,
        taglist_buttons = taglist_buttons,
        tasklist_buttons = tasklist_buttons,
    })

    local bar_widget = {
        layout = wibox.layout.align.horizontal,
        nil,
        {
            widget = wibox.container.margin,
            margins = dpi(7),
            tags_widget,
        },
        nil,
    }

    local hb = hover_bar.create({
        screen = s,
        height = dpi(40),
        widget = bar_widget,
        is_primary = false,
    })

    return hb
end

return bar
```

- [ ] **Step 2: Validate syntax**

Run: `awesome -c /home/tlh/.config/awesome/rc.lua --check`

Expected: No syntax errors.

- [ ] **Step 3: Commit**

```bash
git add ui/bar/init.lua
git commit -m "feat: use hover_bar module for wibar creation"
```

---

### Task 3: Update ui/init.lua for hover bar

**Files:**
- Modify: `ui/init.lua`

- [ ] **Step 1: Update bar setup in ui/init.lua**

The bar is no longer an `awful.wibar`, so we need to remove the `awful.placement.bottom` call since positioning is now handled by `hover_bar`. Modify lines 68-73 in `ui/init.lua`:

Find this section (lines 43-74):
```lua
local success, err = pcall(function()
    if s == capi.screen.primary then
        s.bar = bar.create_primary(s)
        s.bar:connect_signal("property::visible", function()
            if control_panel.visible == true then
                gtimer.delayed_call(function()
                    awful.placement.bottom_right(control_panel, {
                        honor_workarea = true,
                        margins = beautiful.useless_gap,
                    })
                end)
            end

            if launcher.visible == true then
                gtimer.delayed_call(function()
                    awful.placement.bottom_left(launcher, {
                        honor_workarea = true,
                        margins = beautiful.useless_gap,
                    })
                end)
            end
        end)
    else
        s.bar = bar.create_secondary(s)
    end

    s.bar.visible = true
    awful.placement.bottom(s.bar, {
        honor_workarea = false,
        margins = { bottom = 0 },
    })
end)
```

Replace with:
```lua
local success, err = pcall(function()
    if s == capi.screen.primary then
        s.bar = bar.create_primary(s)
        s.bar.bar:connect_signal("property::visible", function()
            if control_panel.visible == true then
                gtimer.delayed_call(function()
                    awful.placement.bottom_right(control_panel, {
                        honor_workarea = true,
                        margins = beautiful.useless_gap,
                    })
                end)
            end

            if launcher.visible == true then
                gtimer.delayed_call(function()
                    awful.placement.bottom_left(launcher, {
                        honor_workarea = true,
                        margins = beautiful.useless_gap,
                    })
                end)
            end
        end)
    else
        s.bar = bar.create_secondary(s)
    end

    -- Hover bar manages its own visibility and positioning
end)
```

- [ ] **Step 2: Validate syntax**

Run: `awesome -c /home/tlh/.config/awesome/rc.lua --check`

Expected: No syntax errors.

- [ ] **Step 3: Commit**

```bash
git add ui/init.lua
git commit -m "feat: update ui/init.lua for hover bar handling"
```

---

### Task 4: Test and debug

- [ ] **Step 1: Start test environment**

Run: `./bin/awmtt-ng.sh start`

Expected: Xephyr nested session starts.

- [ ] **Step 2: Restart Awesome to load changes**

Run: `./bin/awmtt-ng.sh restart`

Expected: Awesome reloads with new config.

- [ ] **Step 3: Test hover behavior**

1. Move mouse to bottom 3px of screen
2. Verify bar slides up smoothly
3. Move mouse onto the bar
4. Move mouse away from bar and trigger zone
5. Wait 3 seconds
6. Verify bar slides down

If errors occur, check the log output and fix issues. Iterate until working.

- [ ] **Step 4: Test on all screens**

If multiple monitors, verify hover works independently on each screen.

- [ ] **Step 5: Test window geometry**

Open a terminal and maximize it. Verify the window uses the full screen height (bar appears on top, not reserving space).

- [ ] **Step 6: Final commit if any fixes were needed**

```bash
git add -A
git commit -m "fix: resolve hover bar issues"
```
