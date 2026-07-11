---
name: awesome-keybinding
description: Add and maintain keyboard shortcuts in the AwesomeWM config at /etc/nixos/external/awesome. Use when adding a new keybinding, modifying an existing one, or debugging dual-bind/keyd throttle issues.
---

# AwesomeWM Keybinding Guide

This skill encodes the exact patterns used by the AwesomeWM config at
`/etc/nixos/external/awesome` for adding and maintaining keyboard shortcuts.
Follow these conventions precisely — the config uses a specific file layout,
binding API, and dual-bind/keyd workaround pattern.

## When to Use

- Adding a new keyboard shortcut to the config
- Modifying an existing keybinding (modifier, key, or action)
- Debugging a keybinding that doesn't fire or fires twice
- Adding a hardware/media key with a keycode fallback for `keyd`
- Creating a new keybinding category file

---

## File Organization

All keybindings live under `configuration/keybind/`, split by category:

| File | Purpose | Registered Via |
|------|---------|----------------|
| `hardware.lua` | Volume, mute, media keys, brightness, screenshot, lockscreen | `append_global_keybindings` |
| `launcher.lua` | App launcher, terminal, menubar | `append_global_keybindings` |
| `layout.lua` | Layout switching, client swapping, master/column controls | `append_global_keybindings` |
| `layout_custom.lua` | Custom tiling layout hotkey descriptions (grid, map) | `hotkeys_popup.add_hotkeys` |
| `focus.lua` | Focus movement between clients/screens | `append_global_keybindings` |
| `system.lua` | Reload, quit, panel toggles, power menu, Alt+Tab keygrabber | `append_global_keybindings` |
| `tags.lua` | Tag navigation, client-to-tag movement, keygroup-based numrow bindings | `append_global_keybindings` |
| `window.lua` | Close, floating, maximize, resize, snap, minimize | `append_client_keybindings` (via `request::default_keybindings`) |
| `mouse.lua` | Mouse bindings for root window and client titlebars | `append_global_mousebindings` + `append_client_mousebindings` |
| `init.lua` | Aggregator — defines `modkey`, requires all modules, calls `set_keybindings()` | — |

### Adding a New Keybinding File

1. Create `configuration/keybind/<category>.lua`
2. Add `require("configuration.keybind.<category>")` to `configuration/keybind/init.lua`
3. Follow the binding format for global or client keys (see below)

---

## Modkey

Always define at the top of each keybinding file:

```lua
local modkey = "Mod4"
```

The primary modifier is `Mod4` (Super/Windows key). This is defined in every
file independently — do not pull it from a shared module.

---

## Binding Format

### Global Keybindings

Registered with `awful.keyboard.append_global_keybindings()`:

```lua
awful.keyboard.append_global_keybindings({
    awful.key(
        { modkey, "Shift" },   -- modifiers (table)
        "f",                    -- key string or keysym
        function()              -- callback
            -- action
        end,
        { description = "description", group = "group_name" }
    ),
})
```

### Client Keybindings

Registered via the `request::default_keybindings` signal with
`awful.keyboard.append_client_keybindings()`. The callback receives the
focused client `c`:

```lua
capi.client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key(
            { modkey, "Shift" },
            "w",
            function(c)          -- callback receives client
                c:kill()
            end,
            { description = "close focused window", group = "Window" }
        ),
    })
end)
```

### Keygroup Bindings (Number Row)

Used for tag navigation (1-9) where the same binding shape repeats per index:

```lua
awful.key({
    modifiers  = { modkey },
    keygroup   = "numrow",
    description = "View Tag",
    group      = "Tags",
    on_press   = function(index)
        local screen = awful.screen.focused()
        if screen and screen.tags and screen.tags[index] then
            screen.tags[index]:view_only()
        end
    end,
})
```

### Passing a Function Reference

When the callback has no setup, pass the function directly:

```lua
awful.key(
    { modkey, "Shift" },
    "Left",
    awful.tag.viewprev,
    { description = "View Previous Tag", group = "Tags" }
)
```

---

## Dual-Bind Pattern (keyd Workaround)

When `keyd` intercepts keysym-based events (common for XF86Audio* keys),
bind **both** the keysym **and** the keycode:

```lua
-- Keysym binding (preferred — works when xkb maps it)
awful.key({}, "XF86AudioRaiseVolume", function()
    handle_volume_change("+5")
end, { description = "increase volume", group = "Hardware" }),

-- Keycode fallback (catches events keyd steals from xkb)
-- #123 = KEY_VOLUMEUP, #122 = KEY_VOLUMEDOWN, #121 = KEY_MUTE
awful.key({}, "#123", function()
    handle_volume_change("+5")
end, { description = "increase volume (keycode)", group = "Hardware" }),
```

### Common Keycodes

| Keycode | Kernel Constant | Maps To |
|---------|----------------|---------|
| `#123` | `KEY_VOLUMEUP` | Volume up |
| `#122` | `KEY_VOLUMEDOWN` | Volume down |
| `#121` | `KEY_MUTE` | Mute toggle |

### Throttle (Prevent Double-Fire)

When dual-binding, share a throttle closure to prevent both bindings from
firing for the same physical press. Always use `glib.get_monotonic_time()`
(microseconds) — **not** `os.clock()` (CPU time, not wall clock):

```lua
local glib = require("lgi").GLib

local volume_tick = 0
local THROTTLE_US = 80000  -- 80ms in microseconds

local function handle_volume_change(rel)
    local now = glib.get_monotonic_time()
    if now - volume_tick < THROTTLE_US then return end
    volume_tick = now

    -- actual action (e.g., call service method)
end
```

The throttle variable and threshold live at the top of the file, shared
across all bindings that invoke the same handler.

---

## Naming Groups

Use these exact group names for the hotkeys popup (F1 help):

| Group | Used In |
|-------|---------|
| `"Hardware"` | `hardware.lua` |
| `"Launcher"` | `launcher.lua` |
| `"Layout"` | `layout.lua` |
| `"Focus"` | `focus.lua` |
| `"System"` | `system.lua` |
| `"Tags"` | `tags.lua` |
| `"Window"` | `window.lua` |
| `"client"` | `mouse.lua` (mousebindings) |

Group names are title-cased: `"Hardware"`, not `"hardware"`.

---

## Shell Commands

For system commands that need PATH resolution (NixOS), always use
`awful.spawn.with_shell()` — not `awful.spawn()`:

```lua
awful.key({}, "XF86AudioMute", function()
    awful.spawn.with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle")
end)
```

---

## Mouse Bindings

### Global (Root Window)

```lua
awful.mouse.append_global_mousebindings({
    awful.button({}, 3, function()
        -- right-click on desktop
    end),
})
```

### Client Titlebar

```lua
capi.client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({ modkey }, 1, function(c)
            c:activate({ context = "mouse_click", action = "mouse_move" })
        end),
        awful.button({ modkey }, 3, function(c)
            c:activate({ context = "mouse_click", action = "mouse_resize" })
        end),
    })
end)
```

---

## Capis Table

Capture native AwesomeWM globals at the top of each file using a `capi`
table to avoid global lookups:

```lua
local capi = {
    awesome = awesome,
    client  = client,
    screen  = screen,
}
```

Include only the globals the file actually uses.

---

## step-by-step: Adding a New Keybinding

1. **Pick the category** — determine which file in `configuration/keybind/`
   the binding belongs to. If none fit, create a new file.
2. **Read the file** — check existing patterns and the modkey definition.
3. **Add the binding** — use `awful.key()` inside the appropriate
   `append_global_keybindings` or `append_client_keybindings` call.
   Provide a `{ description, group }` hint table.
4. **Dual-bind if hardware** — for XF86Audio* keys, add both the keysym
   and keycode binding, and add a throttle if one doesn't exist.
5. **Register new files** — if you created a new file, add a
   `require("configuration.keybind.<name>")` line to `init.lua`.
6. **Test** — run `awesome -c rc.lua --check` to validate syntax, then
   reload with Super+R and test the binding.

---

## Examples

### ✅ Good: Adding a hardware brightness key

```lua
-- In configuration/keybind/hardware.lua, inside append_global_keybindings

awful.key({}, "XF86MonBrightnessUp", function()
    if brightness_service and brightness_service.increase then
        brightness_service:increase(function(value)
            brightness_osd:show(value)
        end)
    end
end, { description = "increase brightness", group = "Hardware" }),
```

### ✅ Good: Adding a client window key

```lua
-- In configuration/keybind/window.lua, inside append_client_keybindings

awful.key({ modkey }, "w", function(c)
    c:kill()
end, { description = "close focused window", group = "Window" }),
```

### ✅ Good: Adding a system key

```lua
-- In configuration/keybind/system.lua, inside append_global_keybindings

awful.key(
    { modkey },
    "r",
    capi.awesome.restart,
    { description = "reload awesome", group = "System" }
),
```

### ❌ Bad: Missing description/group

```lua
awful.key({ modkey }, "x", function() do_thing() end)
```
No description means the binding won't appear in the F1 help, making it
undiscoverable.

### ❌ Bad: Using `os.clock()` for throttle

```lua
if os.clock() - last < 0.08 then return end
```
`os.clock()` returns CPU time, not wall clock time — it will always be ~0
for a single-threaded Lua process, so the throttle never fires.

### ❌ Bad: Using `awful.spawn()` for shell commands

```lua
awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
```
On NixOS, `pactl` may not be on the default PATH available to
`awful.spawn()`. Use `awful.spawn.with_shell()` instead.

---

## Validation

After making changes, always run:

```bash
awesome -c rc.lua --check
```

Then reload with `Mod4+R` (or `Super+R`) and test the binding in the nested
session with `./bin/awmtt-ng.sh restart`.
