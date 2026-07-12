# service/screenshot

## Purpose
Wrapper over `maim` (capture) and `satty` (annotate). Captures land in `$HOME/Pictures/` by default; override the destination by setting `screenshot.OUTPUT_DIR` before the first capture.

## API
- `service.screenshot.get_default()` — singleton accessor.
- `screenshot.OUTPUT_DIR` — output directory (default `~/.Pictures`). Mutate before first capture to change.
- `take(args?)` — capture with arbitrary `maim` flags. Don't pass user input — use the typed wrappers below.
- `take_full()` — full-screen capture.
- `take_select()` — region selected with the mouse.
- `take_delay(seconds?)` — full-screen after a delay (default 1s).
- `annotate(path)` — open an existing PNG in `satty`.
- `delete(path)` — remove a screenshot file.
- `copy_screenshot(path)` — copy a PNG to the system clipboard (requires GTK).

## Implementation notes
- All path arguments are run through `shell_quote` (single-quote escaping) before being interpolated into shell commands — this prevents injection if a path contains spaces or `'` characters.
- Failures during `take` surface as both a `naughty.notification` and the `canceled` signal.
- `copy_screenshot` is a no-op on systems where the GIR bindings failed to load.
