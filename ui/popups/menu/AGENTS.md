# ui/popups/menu

## Purpose
Right-click menu singleton. Provides the desktop context menu (awesome config / restart / power) and the per-client context menu (minimize / maximize / close / …). Backs the right-click bindings in `configuration/keybind/mouse.lua`.

## API
- `menu.get_default()` — singleton accessor.
- `:show_desktop_menu()` / `:toggle_desktop_menu()` — desktop menu.
- `:show_client_menu(c?)` / `:toggle_client_menu(c?)` — per-client menu; defaults to the focused client.
- `:hide()` — dismiss whichever menu is open.

## Implementation notes
- The menu widget is built lazily and only one is shown at a time.
- File-manager and screenshot launches go through `Gio.AppInfo.get_default_for_type` with `pcall` guards.
