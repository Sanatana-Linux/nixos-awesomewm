print("DEBUG: ui.lockscreen init.lua is being loaded")
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local shapes = require("modules.shapes")
local pam = require("lib.liblua_pam").pam
local gears = require("gears")

local lockscreen = {}

local function new()
    -- Placeholder functions to fix loading error
    local function getRandom()
        return math.random() * 2 * math.pi
    end
    local function reset(success)
        -- This function likely resets the UI state.
        -- You may need to implement its contents.
    end

    local auth = function(password)
        return pam.auth_current_user(password)
    end

    local header = wibox.widget({
        {
            {
                image = beautiful.awesome_icon,
                clip_shape = shapes.rrect_8,
                forced_height = dpi(180),
                opacity = 1,
                forced_width = dpi(180),
                halign = "center",
                widget = wibox.widget.imagebox,
            },
            id = "arc",
            widget = wibox.container.arcchart,
            max_value = 100,
            min_value = 0,
            value = 0,
            rounded_edge = false,
            thickness = dpi(8),
            start_angle = 4.71238898,
            bg = beautiful.bg,
            colors = { beautiful.fg },
            forced_width = dpi(180),
            forced_height = dpi(180),
        },
        widget = wibox.container.place,
        halign = "center",
    })
    local label = wibox.widget({
        markup = "Enter Your Password",
        valign = "center",
        halign = "center",
        id = "name",
        font = beautiful.font_name .. " 14",
        widget = wibox.widget.textbox,
    })

    local check_caps = function()
        awful.spawn.easy_async_with_shell(
            "xset q | grep Caps | cut -d: -f3 | cut -d0 -f1 | tr -d ' '",
            function(stdout)
                if stdout:match("off") then
                    label.markup = "Enter Your Password"
                else
                    label.markup = "HINT: Caps Lock Is ON"
                end
            end
        )
    end

    local promptbox = wibox({
        ontop = true,
        visible = false,
        screen = awful.screen.primary or awful.screen[1],
        bg = beautiful.bg .. "00",
        shape = shapes.rrect(0),
    })

    local background = wibox({
        visible = false,
        ontop = true,
        type = "splash",
    })

    local back_image_widget = wibox.widget({
        id = "bg",
        image = beautiful.wallpaper,
        widget = wibox.widget.imagebox,
        horizontal_fit_policy = "fit",
        vertical_fit_policy = "fit",
    })

    local overlay = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg .. "c1",
    })

    local grabber = nil
    local input = ""

    local function grab()
        input = "" -- Reset input on grab
        grabber = awful.keygrabber({
            auto_start = true,
            stop_event = "release",
            mask_event_callback = true,
            keybindings = {
                awful.key({
                    modifiers = { "Mod1", "Mod4", "Shift", "Control" },
                    key = "Return",
                    on_press = function(_)
                        -- Do nothing, handled in keyreleased_callback
                    end,
                }),
            },
            keypressed_callback = function(_, _, key, _)
                if key == "Escape" then
                    lockscreen:hide()
                    return
                end
                -- Accept only the single charactered key
                -- Ignore 'Shift', 'Control', 'Return', 'F1', 'F2', etc., etc.
                if #key == 1 then
                    header:get_children_by_id("arc")[1].colors =
                        { beautiful.blue }
                    header:get_children_by_id("arc")[1].value = 20
                    header:get_children_by_id("arc")[1].start_angle =
                        getRandom()
                    input = input .. key
                elseif key == "BackSpace" then
                    header:get_children_by_id("arc")[1].colors =
                        { beautiful.blue }
                    header:get_children_by_id("arc")[1].value = 20
                    header:get_children_by_id("arc")[1].start_angle =
                        getRandom()
                    input = input:sub(1, -2)
                    if #input == 0 then
                        header:get_children_by_id("arc")[1].colors =
                            { beautiful.magenta }
                        header:get_children_by_id("arc")[1].value = 100
                    end
                end
            end,
            keyreleased_callback = function(self, _, key, _)
                -- Validation
                if key == "Return" then
                    if auth(input) then
                        lockscreen:hide()
                    else
                        header:get_children_by_id("arc")[1].colors =
                            { beautiful.red }
                        reset(false)
                        input = ""
                    end
                elseif key == "Caps_Lock" then
                    check_caps()
                end
            end,
        })
        grabber:start()
    end

    function lockscreen:show()
        local s = awful.screen.primary or awful.screen[1]
        background.screen = s
        promptbox.screen = s

        background.width = s.geometry.width
        background.height = s.geometry.height
        promptbox.width = s.geometry.width
        promptbox.height = s.geometry.height

        awful.placement.centered(background)
        awful.placement.centered(promptbox)

        local blurwall_path = gears.filesystem.get_cache_dir() .. "lock.jpg"
        local cmd = "convert "
            .. beautiful.wallpaper
            .. " -filter Gaussian -blur 0x6 "
            .. blurwall_path
        awful.spawn.easy_async_with_shell(cmd, function()
            back_image_widget.image = blurwall_path
            background.visible = true
            promptbox.visible = true
            grab()
        end)
    end

    function lockscreen:hide()
        if grabber then
            grabber:stop()
            grabber = nil
        end
        background.visible = false
        promptbox.visible = false
        reset(true)
        input = ""
    end

    background:setup({
        back_image_widget,
        overlay,
        layout = wibox.layout.stack,
    })

    promptbox:setup({
        widget = wibox.widget({
            widget = wibox.container.background,
            shape = shapes.rrect_20,
            bg = beautiful.bg .. "c1",
            {
                widget = wibox.container.margin,
                margins = dpi(30),
                {
                    layout = wibox.layout.align.vertical,
                    {
                        widget = wibox.container.place,
                        valign = "center",
                        {
                            layout = wibox.layout.fixed.vertical,
                            spacing = 10,
                            {
                                font = beautiful.font_name .. " 108",
                                format = "%H:%M",
                                halign = "center",
                                valign = "center",
                                widget = wibox.widget.textclock,
                            },
                            {
                                font = beautiful.font_name .. " 24",
                                format = "%a, %d %B",
                                halign = "center",
                                valign = "center",
                                widget = wibox.widget.textclock,
                            },
                            {
                                label,
                                widget = wibox.container.margin,
                                top = 50,
                            },
                        },
                    },
                    nil, -- Spacer
                    header,
                },
            },
        }),
    })

    check_caps()

    return lockscreen
end

local instance = nil
local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return {
    get_default = get_default,
}
