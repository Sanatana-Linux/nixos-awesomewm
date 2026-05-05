# Architecture Decision Records

## ADR-001: Window Switcher Icon-Only Horizontal Layout

**Context:** A window switcher was needed for Alt+Tab. The source reference (`bling` library) used thumbnails + titles, which added cairo surface complexity. The existing codebase had `styled_button` and `icon_lookup` modules for wibar icon buttons.

**Decision:** Use icon-only horizontal layout with `styled_button.create()` — no titles, no thumbnail capture. Each client is represented by its app icon, styled to match wibar buttons.

**Rationale:**
- Avoids cairo surface capture complexity and performance overhead
- Reuses existing `styled_button` and `icon_lookup` infrastructure
- Matches visual language of the wibar (consistent UX)
- Horizontal layout works well for 2-12 open windows

**Consequences:**
- No thumbnail preview of minimized/obscured windows
- Relies on user recognizing app icons
- Visual state (selected/normal) must be rebuilt on focus change

---

## ADR-002: Rebuild Widget on Focus Change (Not Internal State)

**Context:** The window switcher needs to show which client is currently focused with a visual highlight. The tasklist widget doesn't support per-item selection marking.

**Decision:** Rebuild the entire popup widget on every `client.focus` signal while the switcher is visible, passing `selected = true/false` to each `styled_button.create()` call.

**Rationale:**
- `styled_button` has built-in `set_selected()` support with hover reversion
- Simpler than tracking internal state and manually toggling visual attributes
- Rebuild is fast since there are typically <20 items
- Avoids signal wiring complexity per-button

**Consequences:**
- Brief flash on rebuild (imperceptible at <20 items)
- Focus change signals must be connected correctly to avoid stale state

---

## ADR-003: Emit Signals from Keygrabber, Not Inline Popup

**Context:** The Alt+Tab keygrabber in `system.lua` needed to show/hide the window switcher popup. The original code emitted `window_switcher::turn_on` from the keygrabber start callback.

**Decision:** Keep signal-based communication: keygrabber emits `window_switcher::turn_on` / `window_switcher::turn_off`, and the window_switcher module listens for these signals.

**Rationale:**
- Decouples keybinding from popup implementation
- Allows other code to trigger the switcher (future: launcher integration)
- Follows existing signal patterns in the project (e.g., `lockscreen::visible`)
- The window_switcher module is still loaded as a singleton with `get_default()`

**Consequences:**
- Must ensure the module is `require`d before signals are emitted (done in `system.lua`)
- Signal names are global strings — coordination with other modules needed

---

## ADR-004: Temporary Unminimize During Switcher

**Context:** Minimized clients should appear in the window switcher so the user can select them.

**Decision:** On `turn_on`, collect all minimized clients on the current tag, unminimize them, and set them below other windows. On `turn_off`, re-minimize any that are still valid and weren't the final focus target.

**Rationale:**
- `awful.widget.tasklist.filter.currenttags` only shows visible (non-minimized) clients
- Temporarily unminimizing makes them appear in the icon list
- Lowering them prevents visual disruption during cycling
- Re-minimizing on close restores original state

**Consequences:**
- Brief flash of unminimized windows before the popup appears
- Must track minimized clients per-session to avoid leaking state
