# Reference: x3ric/usr AwesomeWM Config

**Source:** https://github.com/x3ric/usr/tree/main/.config/awesome
**Consumed:** 2026-07-02
**License:** Public (no license specified)

## Overview

A feature-rich AwesomeWM 4.3 configuration by x3ric with a large `lib/` widget/utility
library written from scratch. Organized as flat files (init.lua, keys.lua, rules.lua, etc.)
with a heavy `lib/` directory for reusable components.

## File Layout

```
.config/awesome/
├── init.lua              # Main entry (beautiful init, startup, GC timer)
├── rc.lua                # WM bootstrap (bar, taglist, tasklist, widgets, menus)
├── keys.lua              # All keybindings
├── rules.lua             # Window/client rules
├── layouts.lua           # Layout set definition
├── titlebar.lua          # Client titlebar system (3 modes)
├── signals.lua           # Client/screen signal handlers
├── menu.lua              # Application menu setup
├── env.lua               # Environment config (theme, terminal, browser, etc.)
├── alias.lua             # Tasklist display name aliases
├── appkeys.lua           # Per-application keybinding helpers
├── desktop.lua           # Desktop system monitor widgets
├── edges.lua             # Screen edge mouse triggers
├── logout.lua            # Power off / reboot / suspend logout screen
├── mail.lua              # Mail check config
├── themes/oxoawesome/    # Full theme with svg icons
│   ├── theme.lua         # ~1000 lines of theme configuration
│   └── icons/            # SVG icons organized by component
└── lib/
    ├── init.lua          # Library aggregator
    ├── awesome/          # AwesomeWM builtin overrides (hotkeys_popup)
    ├── layouts/          # Custom layout implementations
    ├── utils/            # Utility functions
    │   ├── init.lua, base.lua, cairo.lua, client.lua
    │   ├── desktop.lua, helpers.lua, key.lua, markup.lua
    │   ├── placement.lua, quake.lua, read.lua, startup.lua
    │   ├── system.lua, table.lua, text.lua, xres.lua
    │   ├── save/         # Tag/position persistence
    │   ├── service/      # Logout, navigator, dfparser
    │   └── tweaks/       # unfocustransparency, focusmouse, welcome, swallow
    └── widgets/          # Widget system (custom Cairo-drawn widgets)
        ├── init.lua
        ├── bar/          # Panel widgets (taglist, tasklist, layoutbox, etc.)
        ├── desktop/      # Desktop meter widgets
        ├── float/        # Popup widgets (apprunner, appswitcher, player, etc.)
        └── gauge/        # Custom Cairo gauge drawing primitives
```

## Key Architecture Patterns

### Widget System (lib/widgets/)
Four subsystems:
- **gauge/** — Cairo drawing primitives: tag, task, audio, monitor, graph, icon, separator
- **bar/** — Panel wibar widgets: taglist, tasklist, layoutbox, textclock, battery, pulse, etc.
- **float/** — Popup/overlay widgets: apprunner, appswitcher, player, top, calendar, notify, etc.
- **desktop/** — Desktop system monitor widgets (speedmeter, multimeter, multiline, calendar)

### Titlebar System (3 modes)
- **Mini** (`style.base.size=8`): Minimal focus line indicator
- **Compact** (`style.compact.size=16`): Focus line + state marks + close/min/max
- **Full** (`style.iconic.size=24`): Menu button, app icon, title, state buttons, close/min/max
- User cycles through modes at runtime via `float.bartip`

### Keybinding System (lib/utils/key.lua)
- `utils.key.build()` — builds key tables from raw descriptor arrays
- Keys use descriptor format: `{ modifiers, key, callback, { description, group } }`
- `awful.keyboard.append_global_keybindings()` for registration
- Group names: Main, Actions, Client focus, Layouts, Window control, Launchers, etc.

### Theme (oxoawesome)
- Dark theme with configurable `colormain` and `colorurgent`
- Color palette: bg=#161616, wibox=#000000, text=#aaaaaa, highlight=#e0e0e0
- Font: OCR A (monospace), Terminus for some elements
- Icon theme: Papirus (with SVG overrides)
- Extensive self.gauge.*, self.widget.*, self.float.* style tables

### Noteworthy Techniques

| Technique | Description |
|-----------|-------------|
| App-specific hotkeys | `Mod4+Shift+F1` shows keybinding helper for current app (keys from appkeys.lua) |
| Desktop widgets | System monitors (CPU, RAM, disk, network, temps) drawn on the desktop itself |
| Screen edges | Thin invisible wiboxes along screen edges with mouse-triggered actions |
| Bar hider | Auto-hides panel, adjusts floating window positions |
| Quake terminal | Dropdown terminal with `Mod4+F5` |
| Tag columns | Tags arranged in a grid with Shift+Arrow navigation between rows |
| Minitray | Systray with dot-count state indicator |
| Logout screen | Full-screen overlay with graceful shutdown (kills apps with timeout) |
| Window navigator | Tiling window control mode (`Mod4+F2`) with placeholder highlighting |
| Floating window control | `Mod4+Shift+F` → resize/move floating windows with keyboard |
| Keyboard layout switcher | Widget (wibox) with toggle menu |
| Volume change song check | Checks mpc on volume change, shows player if new song |

## Default Keybindings

| Binding | Action |
|---------|--------|
| `Mod4+F1` | Hold: show hotkeys helper |
| `Mod4+Shift+F1` | Hold: app-specific key helper |
| `Mod4+c` | Hold: key sequence (user commands) |
| `Mod4+Return` | Terminal |
| `Mod4+d` | Application launcher |
| `Mod4+s` | Main menu |
| `Mod4+Space` | Next layout |
| `Mod4+Shift+Space` | Previous layout |
| `Mod4+Tab` | App switcher (current tag) |
| `Mod4+Shift+Tab` | App switcher (all tags) |
| `Mod4+f` | Toggle fullscreen |
| `Mod4+q` | Close client |
| `Mod4+m` | Toggle maximize |
| `Mod4+n` | Minimize |
| `Mod4+x` | Prompt box |
| `Mod4+Escape` | xkill |
| `Mod4+F5` | Quake terminal |
| `Mod4+b` | Toggle bar |
| `Mod4+Ctrl+r` | Reload awesome |
| `Mod4+Shift+x` | Logout screen |
| `Mod4+1..9` | Switch to tag N |
| `Mod4+Ctrl+1..9` | Toggle tag N |
| `Mod4+Shift+1..9` | Move client to tag N and view it |
| `Mod4+Ctrl+Shift+1..9` | Toggle client on tag N |
| `XF86AudioRaiseVolume` / `XF86AudioLowerVolume` / `XF86AudioMute` | Volume control |
| `XF86MonBrightnessUp` / `XF86MonBrightnessDown` | Brightness control |

## Window Rules
- Floating by default: DTA, copyq, conky, Discord, Gpick, Arandr, Pinentry, dialogs
- Maximized: Emacs24
- Titlebars enabled: normal, dialog windows (exceptions: Cavalcade, Clipflap, Steam, QEMU)
- Firefox, emacs, obsidian → tag "Full" with titlebars hidden
- Kitty: border_width=0, titlebars hidden
- JetBrains IDEs: floating when skip_taskbar is set

## Layouts (defined in layouts.lua)
In order: tile, max, magnifier, tile.left, tile.bottom, tile.top, floating, spiral, centerwork, centerwork.horizontal

## Relevance

This config shares the same WM and many of the same conventions as the current project.
The `lib/utils/key.lua` keybinding builder, the custom Cairo gauge widgets, the titlebar
system, and the per-app hotkey helper are particularly interesting patterns to reference.
