---@diagnostic disable: undefined-global
--- Scratchpad keybindings.
-- Group: "Window".
--
-- Mod4+Shift+Alt+Return          park focused window in the scratchpad
-- Mod4+Alt+Return                toggle scratchpad window visibility

local awful = require("awful")
local scratchpad = require("core.client.scratchpad")
local modkey = "Mod4"

awful.keyboard.append_global_keybindings({
    -- Park the focused window in the scratchpad buffer.
    awful.key(
        { modkey, "Shift", "Mod1" },
        "Return",
        function()
            scratchpad.add()
        end,
        { description = "park focused window in scratchpad", group = "Window" }
    ),

    -- Toggle the parked scratchpad window's visibility.
    awful.key({ modkey, "Mod1" }, "Return", function()
        scratchpad.toggle()
    end, { description = "toggle scratchpad window", group = "Window" }),
})
