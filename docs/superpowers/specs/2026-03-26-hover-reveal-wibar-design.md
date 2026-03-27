# Hover-Reveal Wibar Design

## Summary
Convert the wibar from a static `awful.wibar` to a hover-revealed, animated wibox that slides in from the bottom when the mouse hovers near the screen edge, and slides out after 3 seconds of mouse absence. The bar displays on top of windows without affecting their geometry.

## Requirements
- Wibar appears on mouse hover at bottom screen edge (3px trigger zone)
- Slide-up animation from bottom (200-300ms duration)
- Auto-hide after 3 seconds of mouse leaving both trigger zone and bar
- Display on top of windows without shifting window geometry (no struts)
- Apply to all screens (primary and secondary)

## Architecture

### Approach
Replace `awful.wibar` with a custom `wibox`:
- `ontop = true` to appear above windows
- No struts (windows use full screen height)
- Manual positioning at screen bottom edge
- Y-position animation for slide effect

### Components

#### 1. Hover Detector (trigger zone)
A thin invisible wibox at screen bottom (3px height):
- Catches mouse enter events
- Starts "show bar" animation on enter
- Starts "hide timer" on mouse leave (3s delay)

#### 2. Animated Bar
A `wibox` with:
- `ontop = true`
- No struts (`struts = { left = 0, right = 0, top = 0, bottom = 0 }`)
- Y-position: `screen.geometry.y + screen.geometry.height` (hidden) to `screen.geometry.y + screen.geometry.height - bar_height` (visible)
- Accepts mouse input (keeps bar visible when hovering bar itself)

#### 3. Animation System
Uses `gears.timer` for smooth slide animation:
- Duration: 250ms
- Easing: ease-out (starts fast, slows at end)
- Target: 60fps

### State Machine
```
Off-screen
  -> (hover zone enter) -> Sliding in
  -> Visible
  -> (mouse leaves bar + zone) -> Wait 3s
  -> Sliding out
  -> Off-screen
```

Rules:
- Any mouse re-entry cancels the 3s countdown
- Mouse on the bar itself counts as "still hovering"

## File Structure
- `ui/bar/init.lua` - modified to use hover_bar module
- `ui/bar/hover_bar.lua` - new module for hover-reveal logic and animation

## Implementation Details

### Hover Bar Module (`ui/bar/hover_bar.lua`)
```lua
-- Creates a hover-reveal bar for a screen
-- Returns: the bar wibox
function hover_bar.create(s, bar_widget)
  -- Create invisible trigger zone at bottom (3px)
  -- Create ontop wibox for actual bar
  -- Set up mouse enter/leave signals
  -- Implement slide animation with gears.timer
end
```

### Animation
Position interpolation using linear interpolation:
```lua
y = start_y + (end_y - start_y) * progress
```
Where progress goes from 0 to 1 over 250ms using `gears.timer`.

### Show/Hide Logic
1. On trigger zone enter: animate bar from hidden to visible position
2. On trigger zone or bar leave: start 3s timer
3. If mouse re-enters either: cancel timer
4. On timer completion: animate bar from visible to hidden position

## Window Geometry Impact
None. The bar uses:
- `type = "normal"` or omitted (not "dock")
- `struts = { left = 0, right = 0, top = 0, bottom = 0 }`
- `ontop = true`

Windows will use the full screen workarea, including the space the bar occupies when visible.

## Edge Cases
- Screen resize: reposition bar on `property::geometry` signal
- Screen removal: destroy bar and trigger zone
- Multiple screens: each screen gets independent hover bar
- Fullscreen clients: bar should still be revealable (ontop = true)
