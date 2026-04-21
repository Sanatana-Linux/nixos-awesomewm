<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# configuration/keybind

## Purpose
Global and client keybindings — defines all keyboard shortcuts using Mod4 (Super) as primary modifier. Organized by category: AwesomeWM control, client manipulation, focus, tags, layout, hardware functions, and mouse bindings.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Aggregator — assembles global and client key tables |
| `awesome.lua` | AwesomeWM control keys (restart, quit, screenshot) |
| `client.lua` | Client window keys (close, move, resize, minimize, max) |
| `focus.lua` | Focus navigation keys (directional, urgent) |
| `hardware_functions.lua` | Hardware keys (volume, brightness, caps lock, WiFi toggle) |
| `layout.lua` | Layout switching keys |
| `mouse.lua` | Mouse button bindings |
| `tags.lua` | Tag navigation and window assignment keys |

## For AI Agents

### Working In This Directory
- Primary modifier is `Mod4` (Super key)
- Global keys go in their respective category files, then are assembled in `init.lua`
- New keybindings must be added to both the category file AND the global keys table
- Hardware function keys use service singletons (audio, brightness, network)