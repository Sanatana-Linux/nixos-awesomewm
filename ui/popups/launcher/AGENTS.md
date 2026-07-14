# ui/popups/launcher

## Purpose
Search-driven GTK app launcher. Reads desktop applications via the GIR bindings at show time (with a small cache) and filters as the user types. Keyboard navigation with `Up`/`Down`/`Return`. Apps marked `Terminal=true` in their `.desktop` file get spawned inside `kitty`, not as direct subprocesses.

## API
- `launcher.get_default()` — singleton accessor.
- `:show()` / `:hide()` / `:toggle()` — visibility.
- `:next()` / `:back()` — move selection, with auto-scroll.
- `:update_entries()` — rebuild the entries list (called on search/scroll/select change).

## Implementation notes
- `launch_app` inspects `Gio.DesktopAppInfo.new(app:get_id())` to read the `Terminal` field, then either `awful.spawn("kitty -e <cmd>")` or `awful.spawn({...})` directly.
- Pre-loads the unfiltered app list once via `gears.filesystem.dir_read_only` and caches it on `_private` to avoid re-scanning on every `show`.
- Applies a debounced filter via a `gears.timer` so each keystroke doesn't immediately re-render.
- Search and lock icons are recolored with `gears.color.recolor_image` at module load (one-time cost).
