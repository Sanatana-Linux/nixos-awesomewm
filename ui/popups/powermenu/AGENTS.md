# ui/popups/powermenu

## Purpose
Paged power / session menu backing the `Mod4+x` system keybinding. Page 1 lists action tiles (lock, suspend, power off, reboot, …). Page 2 is a confirmation dialog for destructive actions. Keyboard navigation via `Up`/`Down`/`Return`.

## API
- `powermenu.get_default()` — singleton accessor.
- `:show()` / `:hide()` / `:toggle()` — visibility.
- `:next()` / `:back()` — move the selection cursor (wraps).
- `:update_elements()` — rebuild the widget tree after mutating `wp.elements`.

## Implementation notes
- The lock action invokes `~/.config/awesome/bin/glitchlock.sh` (not hardcoded — uses `os.getenv("HOME")`).
- The keygrabber is started on `show` and released on `hide` so the popup doesn't capture input while hidden.
- Destructive actions go through a second confirmation page before being executed.
