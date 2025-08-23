local screenlock = {}

local awful = require("awful")
local wibox = require("wibox")
local lgi = require("lgi")
local cairo = lgi.require("cairo")

local function draw_icon(surface, isalive)
    local cr = cairo.Context(surface)
    cr:scale(100, 100)

    -- Main key body
    local x = 0.45 + 0.025
    local y = 0.1
    local keyw = 0.1
    local keyh = 0.6
    cr:set_source_rgb(0.8, 0.8, 0.8)
    cr:rectangle(x, y, keyw, keyh)

    -- Key cuts
    local ycut = y + (keyh / 3 * 2)
    cr:move_to(x, ycut)
    cr:set_line_width(0.01)
    local n = { 0.07, 0.09, 0.05, 0.09 }
    for i = 1, 4 do
        cr:line_to(x, ycut)
        cr:line_to(x - n[i], ycut)
        cr:line_to(x - n[i], ycut - 0.05)
        cr:line_to(x, ycut - 0.05)
        ycut = ycut - 0.1
    end
    cr:fill()

    -- Key bow
    local xc = x + keyw / 2 - 0.025
    local yc = y + keyh + 0.05
    cr:arc(xc, yc, 0.2, 0, 2 * math.pi)
    cr:fill()

    -- Key hole
    cr:set_source_rgb(0, 0, 0)
    cr:arc(xc, yc + 0.06, 0.05, 0, 2 * math.pi)
    cr:fill()
end

local function update_icon(widget, isalive)
    local image = cairo.ImageSurface("ARGB32", 100, 100)
    draw_icon(image, isalive)
    widget:set_image(image)
end

local function pread(cmd)
    local pd = io.popen(cmd, "r")
    if not pd then
        return ""
    end
    local data = pd:read("*a")
    pd:close()
    return data
end

function screenlock.new()
    local widget = wibox.widget.imagebox()
    local state = {
        valid = false,
        brightness = 0,
    }

    widget.configure = function(self, seconds)
        os.execute("xset s " .. seconds .. " 5")
    end

    widget.lock = function(self)
        os.execute(
            "/run/current-system/sw/bin/xss-lock -n /run/current-system/sw/bin/xsecurelock -l -- xsecurelock"
        )
    end

    widget:buttons(awful.util.table.join(awful.button({}, 1, function()
        widget:lock()
    end)))

    widget:configure(300)
    update_icon(widget, true)
    return widget
end

return screenlock
