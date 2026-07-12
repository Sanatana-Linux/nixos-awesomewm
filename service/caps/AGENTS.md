# service/caps

## Purpose
Tracks the kernel Caps-Lock LED state via `setleds` and emits a global `signal::peripheral::caps::state` on change.

## API
- (no `get_default` — this is a module-level signal emitter, not a singleton)
- The signal `signal::peripheral::caps::state` is emitted on the global `awesome` bus with a boolean argument.
- Calling `awesome.emit_signal("signal::peripheral::caps::update")` triggers an immediate re-poll.

## Implementation notes
- Uses `setleds` directly (no `bash -c` wrapper) so the spawn is minimal.
- Polled state is tracked in module-level `caps_state` to avoid duplicate signal emissions.
- Initial poll runs at module load.
