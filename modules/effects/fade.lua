-- https://pastebin.com/3esrXvkv

local timeout = gears.timer.start_new

local function hide(w)
    w.visible = false
    w.opacity = 0
end

local function show(w)
    w.visible = true
    w.opacity = 1
end

return function(widget, speed, delay)
    if effects.busy then
        for _, v in ipairs(effects.timers) do
            v:stop()
        end
    end

    show(widget)

    table.insert(
        effects.timers,
        timeout(delay, function()
            effects.busy = true
            local max = 50

            for f = 1, max do
                table.insert(
                    effects.timers,
                    timeout((f / speed), function()
                        f = f + 1
                        widget.opacity = widget.opacity - 0.02

                        if f == max then
                            effects.busy = false
                            hide(widget)
                        end
                    end)
                )
            end
        end)
    )
end
