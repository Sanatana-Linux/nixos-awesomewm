<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# modules/text_input

## Purpose
Text input widget with cursor, selection, and keyboard focus handling — used for search fields and input dialogs in popups.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Text input widget constructor with keygrabber integration |

## For AI Agents

### Working In This Directory
- Uses `awful.keygrabber` for keyboard input capture
- Follows instantiable widget pattern: `setmetatable({ new = new }, { __call = ... })`
- Accesses internal widgets via `:get_children_by_id("text-input")[1]`
- Styling via `beautiful.text_input_*` theme variables