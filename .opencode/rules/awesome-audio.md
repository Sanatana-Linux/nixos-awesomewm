# AwesomeWM Audio Service Conventions

## pactl Path
All pactl commands MUST use absolute path or `awful.spawn.with_shell()`:
```lua
-- CORRECT: with_shell resolves PATH on NixOS
awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ 100%")

-- CORRECT: absolute path from NixOS
awful.spawn("/run/current-system/sw/bin/pactl set-sink-volume @DEFAULT_SINK@ 100%")

-- WRONG: awful.spawn() without full path won't work
awful.spawn({"pactl", "set-sink-volume", ...})  -- DON'T
```

## Keep-Alive Timer
PipeWire suspends idle sinks after ~5 seconds. Use a `gears.timer` to prevent this:
```lua
local keep_alive = gears.timer {
    timeout = 5,
    autostart = true,
    call_now = false,
    callback = function()
        awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ 100%")
    end,
}
```

## Throttle — Use glib, NOT os.clock()
```lua
-- CORRECT: glib.get_monotonic_time() is wall-clock microseconds
local now = glib.get_monotonic_time() / 1000  -- convert to ms

-- WRONG: os.clock() returns CPU time, not wall clock
local now = os.clock() * 1000  -- DON'T — silently breaks throttling
```

## Signal Convention
Audio emits: `default-sink::volume`, `default-sink::mute`, `default-source::volume`, `default-source::mute`

## Sink Data Callback
For async pactl reads, use `awful.spawn.easy_async_with_shell()`. Fire the OSD callback on first response — do NOT wait for both pactl queries:
```lua
awful.spawn.easy_async_with_shell("pactl get-sink-volume @DEFAULT_SINK@", function(stdout)
    local volume = parse_volume(stdout)
    self:emit_signal("default-sink::volume", volume)
    -- Fire callback immediately — don't wait for second query
    if callback then callback(volume) end
end)
```
