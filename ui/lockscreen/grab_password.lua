--- Lock screen password grabber.
-- Launches an `awful.prompt` that captures keyboard input, animates the
-- lock icon on each keystroke, and authenticates via PAM when the user
-- presses Enter. Re-prompts on failure.
-- @module ui.lockscreen.grab_password

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local config_dir = gears.filesystem.get_configuration_dir()
package.cpath = package.cpath .. ";" .. config_dir .. "lib/?.so;"
local pam = require("liblua_pam")

local lock_animation = require("ui.lockscreen.lock_animation")
local click_to_hide = require("modules.infra.click_to_hide")
local navigator = require("modules.layouts.widgets.navigator")

--- Drain popup escape-grabbers by hiding every registered popup.
-- `awful.prompt.run` does NOT return a grabber handle, so the prompt
-- grabber cannot be tracked and stopped individually. However, the
-- only *other* grabbers that can leak are escape-listeners started by
-- `modules.infra.click_to_hide` when a popup is visible. Hiding all
-- registered popups fires each popup's `property::visible = false`
-- handler, which calls `deactivate_popup` and stops the escape
-- keygrabber, draining it from `awful.keygrabber`'s internal stack.
-- When the stack empties, `capi.keygrabber.stop()` releases the
-- native X keyboard grab.
-- @local
local function drain_popup_grabbers()
    pcall(click_to_hide.hide_all)
    -- The Mod4+F2 layout navigator grabs the keyboard via the low-level
    -- `capi.keygrabber` (not the awful.keygrabber stack), so it is NOT
    -- drained by hiding popups. If it was active when the screen locked,
    -- its native X grab would persist after unlock, leaving the keyboard
    -- dead. Close it (guarded by its `active` flag) so the native grab
    -- is released. `close()` is a no-op when the navigator is inactive.
    if navigator.active then
        pcall(navigator.close, navigator)
    end
end

--- Start grabbing password input: show prompt with Escape/Ctrl+Del reset hooks.
-- On Enter, passes input to PAM auth. On success, drains grabbers and
-- emits `lockscreen::visible = false`. On failure, shows fail animation
-- and re-grabs.
-- @local
local function grab_password()
    --- Reset and re-grab on Escape / Ctrl+Delete.
    -- @local
    local function reset_input()
        lock_animation.reset()
        grab_password()
    end

    awful.prompt.run({
        hooks = {
            -- Do not cancel input with Escape or Ctrl+Del
            -- This will just clear any input received so far.
            { {}, "Escape", reset_input },
            { { "Control" }, "Delete", reset_input },

            -- Prevent Awesomewm restarting
            { { "Control", "Mod4" }, "r", reset_input },
        },

        keypressed_callback = function(mod, key, cmd)
            -- Only count single character keys (thus preventing
            -- "Shift", "Escape", etc from triggering the animation)
            if #key == 1 then
                lock_animation.key_animation("insert")
            elseif key == "BackSpace" then
                lock_animation.key_animation("remove")
            end
        end,

        exe_callback = function(input)
            -- Check input
            if pam.auth_current_user(input) then
                lock_animation.reset()
                -- Drain popup escape-grabbers before emitting the
                -- unlock signal. awful.prompt.run already stopped its
                -- own grabber on Enter before calling this callback,
                -- but any popup escape-grabber must also be stopped
                -- or the native X keyboard grab stays active.
                drain_popup_grabbers()
                awesome.emit_signal("lockscreen::visible", false)
            else
                lock_animation.fail()
                grab_password()
            end
        end,

        textbox = wibox.widget.textbox(),
    })
end

-- When the lockscreen is dismissed by any path (root-click in
-- ui/init.lua, force-unlock, etc.), drain popup escape-grabbers so
-- the native X keyboard grab is released. The prompt's own grabber
-- is already stopped by awful.prompt.run before exe_callback fires.
awesome.connect_signal("lockscreen::visible", function(visible)
    if not visible then
        drain_popup_grabbers()
    end
end)

return grab_password
