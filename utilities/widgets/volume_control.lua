return function(step)
  local cmd
  if step == 0 then
    cmd = "pactl set-sink-mute @DEFAULT_SINK@ toggle"
  else
    sign = step > 0 and "+" or ""
    cmd = "pactl set-sink-mute @DEFAULT_SINK@ 0 && pactl set-sink-volume @DEFAULT_SINK@ "
        .. sign
        .. tostring(step)
        .. "%"
  end
  awful.spawn.with_shell(cmd)
end
