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

--- Drain every keyboard grab before releasing the lockscreen.
-- The lockscreen is fullscreen + `ontop = true` and owns *all* keyboard
-- input, so any grabber still in `awful.keygrabber`'s internal stack when
-- we unlock is, by definition, stale and must be flushed. There are three
-- classes of grabber:
--
--   1. The password prompt's own grabber. `awful.prompt.run` does NOT
--      return a handle, so it cannot be stopped individually. On the
--      *normal* unlock path (correct password → Enter) `prompt.run` stops
--      its own grabber inside `exec()` before `exe_callback` fires, so the
--      stack is already empty. But on the *force-unlock* path
--      (`lockscreen::visible = false` emitted directly — e.g. root-click in
--      ui/init.lua), the prompt is still running and its grabber leaks.
--      The only reliable way to drop it is to flush the whole stack.
--
--   2. Escape-listeners started by `modules.infra.click_to_hide` while a
--      popup was visible. Hiding all registered popups fires each popup's
--      `property::visible = false` handler, which calls `deactivate_popup`
--      and stops the escape keygrabber.
--
--   3. The Mod4+F2 layout navigator's native grab (`capi.keygrabber`),
--      which is NOT in the awful.keygrabber stack. Close it directly.
--
-- `awful.keygrabber.stop()` with no argument removes the *last* grabber
-- from the stack (and only releases the native X grab when the stack
-- empties), so we call it repeatedly to flush the entire stack. Calling it
-- on an empty stack is a harmless no-op. Flushing is safe here: the
-- lockscreen is exclusive, so nothing legitimately owns a grab while it is
-- up.
-- @local
local function drain_popup_grabbers()
    pcall(click_to_hide.hide_all)
    -- Flush the entire awful.keygrabber stack. This drops the password
    -- prompt's own grabber on the force-unlock path, plus any leaked
    -- popup escape-grabbers. stop() is idempotent on an empty stack.
    for _ = 1, 20 do
        pcall(awful.keygrabber.stop)
    end
    -- The Mod4+F2 layout navigator grabs the keyboard via the low-level
    -- `capi.keygrabber` (not the awful.keygrabber stack), so it is NOT
    -- drained by the flush above. If it was active when the screen locked,
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
-- ui/init.lua, force-unlock, etc.), drain all keygrabbers so the
-- native X keyboard grab is released. On the force-unlock path the
-- password prompt is still running, so its grabber must be flushed
-- too — drain_popup_grabbers() handles this.
awesome.connect_signal("lockscreen::visible", function(visible)
    if not visible then
        drain_popup_grabbers()
    end
end)

return grab_password
