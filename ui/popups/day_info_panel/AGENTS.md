# ui/popups/day_info_panel

## Purpose
Bottom-right calendar popup, shown by `Mod4+d`. Animates in/out with a slide+fade. Click-outside hides it via the centralized `modules.click_to_hide` helper.

## API
- `day_info_panel.get_default()` — singleton accessor.
- `:show()` / `:hide()` / `:toggle()` — visibility with animation.

## Implementation notes
- Calendar is the `modules.calendar` widget configured for `sun_start = false` and rounded day cells.
- The show animation moves `self.y` up by `dpi(20)` while fading opacity 0→1; the hide animation reverses that.
- Idempotent `show` — calling it twice doesn't re-trigger the animation, so the `Mod4+d` binding is safe to mash.
