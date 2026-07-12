# ui/popups/window_switcher

## Purpose
Alt+Tab-style window switcher. Renders a horizontal row of client icon buttons (no titles) at the center of the focused screen. The currently-focused client gets a highlighted border. Auto-hides when the focused tag has no clients.

## API
- `window_switcher.get_default()` — singleton accessor.
- `:show()` / `:hide()` — show or hide the popup.
- The `awesome` signals `window_switcher::turn_on` / `window_switcher::turn_off` are emitted by the Alt+Tab keygrabber in `system.lua` to drive the visibility.

## Implementation notes
- One `awful.popup` is constructed per show. Hide releases the widget reference and triggers `collectgarbage("collect")` so the cached client list is reclaimed promptly.
- Client icons come from `modules.icon-lookup` (centralized lookup, with `Colloid-Dark` fallback).
- Uses `modules.styled_button` (not the regular hover button) so it can call `set_selected` on the focused entry.
