# service/audio

## Purpose
PulseAudio / PipeWire volume and mute control for the default sink and source. Polls `pactl` on demand and emits `default-sink::{volume,mute}` and `default-source::{volume,mute}` signals.

## API
- `service.audio.get_default()` — singleton accessor.
- `set_default_sink_volume(value, callback?)` — write a 0..100 percentage.
- `toggle_default_sink_mute(callback?)` — flip mute state.
- `get_default_sink_data(callback?)` — re-poll and emit signals if changed.
- `set_default_source_volume(value)`, `toggle_default_source_mute()`, `get_default_source_data(callback?)` — same for the source (microphone).

## Implementation notes
- `get_default_sink_data` reads volume + mute in a single shell call (one `easy_async_with_shell` spawn), parsing `field=value` output.
- The initial poll at construction is wrapped in `pcall` so a missing `pactl` doesn't kill the awesome startup.
- All numeric state changes go through `tonumber()` and `nil` guards so empty / malformed output is dropped silently.
