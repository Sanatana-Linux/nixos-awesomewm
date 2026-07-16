# ui/popups/screenshot_popup

## Purpose
Three-tile popup that drives `service.screenshot`. Backs the `Print` system key (`hardware.lua`).

## API
- `screenshot_popup.get_default()` — singleton accessor.
- `:show()` / `:hide()` / `:toggle()` — visibility. `show` re-centers the popup on screen.

## Implementation notes
- The three buttons are `Fullscreen` (`screenshot_service:take_full`), `Region` (`take_select`), `Delay 3s` (`take_delay(3)`). All three close the popup before invoking the service.
- `click_to_hide` integration makes outside-click hide the popup.
- Background is `beautiful.bg .. "bb"` with the `bg` color, falls back to opaque `#000000bb` if the theme doesn't define `bg`.
