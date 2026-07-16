# ui/popups/battery

## Purpose
Detailed battery card with arc charts. Subscribes to `service.battery` for the level/charging/health readings and to `service.system_info` for CPU/RAM/swap/disk summaries. Backs the `Mod4+B` system keybinding (`system.lua`).

## API
- `battery_popup.get_default()` — singleton accessor.
- The popup reacts to clicks on the action chips (htop, yazi, nvtop) by spawning `kitty -e <cmd>`.

## Implementation notes
- The popup is constructed lazily (`new()` only runs when first requested). Construction reads the cached service state once and wires signal handlers.
- Each chart is an `arc_chart.new({...})` widget that animates between values via the `modules.animations` framework.
- The popup is created inside a single local function — no `function battery_popup:toggle()` exports. The toggle is wired through `connect_signal("property::visible")`.
