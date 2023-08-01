local awful = require("awful")
local beautiful = require("beautiful")
local step = 5
local gfs = require("gears.filesystem")
local M = {}

local function spawn(cmd)
    awful.spawn.easy_async(cmd, function() end)
end

function M.play()
    awful.spawn(
        "pacat --property=media.role=event "
            .. gfs.get_configuration_dir()
            .. "themes/assets/sounds/notify2.wav"
    )
end

function M.startup()
    awful.spawn(
        "pacat --property=media.role=event "
            .. gfs.get_configuration_dir()
            .. "themes/assets/sounds/startup.wav"
    )
end

function M.get_volume_state()
    awful.spawn.easy_async("pactl list sinks", function(stdout)
        local mute = stdout:match("Mute:%s+(%a+)")
        local volpercent = stdout:match("%s%sVolume:[%s%a-:%d/]+%s(%d+)%%")

        if mute == "yes" then
            mute = true
        else
            mute = false
        end

        volpercent = tonumber(volpercent)

        return volpercent, mute
    end)
end

function get_volume_percent()
    awful.spawn.easy_async("pactl list sinks", function(stdout)
        local volpercent = stdout:match("%s%sVolume:[%s%a-:%d/]+%s(%d+)%%")

        volpercent = tonumber(volpercent)

        return volpercent
    end)
end

function M.get_mute()
    awful.spawn.easy_async("pactl list sinks", function(stdout)
        local mute = stdout:match("Mute:%s+(%a+)")
        if mute == "yes" then
            mute = 1
        else
            mute = 0
        end
        return mute
    end)
end

function M.volumeUp()
    spawn("pactl set-sink-volume @DEFAULT_SINK@ +" .. step .. "%")
    next_vol = M.get_volume_level()
    awesome.emit_signal("signal::volume", next_vol, nil)
end

function M.volumeDown()
    next_vol = M.get_volume_level()
    awful.spawn.with_shell("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0")
    awful.spawn.with_shell(
        "wpctl set-volume @DEFAULT_AUDIO_SINK@" .. step .. "%-"
    )
    awesome.emit_signal("widget::volume")

    awesome.emit_signal("signal::volume", next_vol, nil)
end

function M.setVolume(vol)
    spawn("pactl set-sink-volume @DEFAULT_SINK@ " .. vol .. "%")
    next_vol = M.get_volume_level()
    mute = M.get_mute
    awesome.emit_signal("signal::volume", next_vol, mute)
end

function M.muteVolume()
    spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
    mute = M.get_mute
    awesome.emit_signal("signal::volume", nil, mute)
end

return M
