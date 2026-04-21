<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# modules/backdrop

## Purpose
Semi-transparent overlay placed behind popup windows. Creates a full-screen wibox with alpha-blended background that picom applies blur to via window name targeting (`awesome-backdrop`).

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Backdrop singleton — show/hide with popup association |

## For AI Agents

### Working In This Directory
- Uses `wibox({ type = "utility", name = "awesome-backdrop" })` for picom blur targeting
- Background color: `beautiful.backdrop_color` (default `"#00000080"`)
- Only one backdrop visible at a time; associated with the active popup
- Picom's `blur-background-rule` matches `name = 'awesome-backdrop'`