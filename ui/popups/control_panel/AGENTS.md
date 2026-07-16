# ui/popups/control_panel

## Purpose
Multi-page control overlay. Pages: home (system stats), audio sliders, brightness, network (applet), bluetooth (applet), notifications. Backs `Mod4+P` (launcher.lua) and `Mod4+E` (system.lua).

## API
- `control_panel.get_default()` — singleton accessor.
- `:show()` / `:hide()` / `:toggle()` — visibility. `hide` animates a slide-down + fade-out.
- `:show_network()` / `:show_bluetooth()` — switch to the applet pages (also accessible from the home page).

## Implementation notes
- The panel is built as a single popup with a swappable page container (`modules.page_container`).
- Each applet (network, bluetooth) lives in its own subdirectory and is mounted when the user navigates to that page.
- On show, the audio service is poked to refresh sink/source data so the sliders show current values.
- Click-outside is wired through `modules.click_to_hide`.
