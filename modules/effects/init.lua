--  _______         __                  __   __
-- |   _   |.-----.|__|.--------.---.-.|  |_|__|.-----.-----.-----.
-- |       ||     ||  ||        |  _  ||   _|  ||  _  |     |__ --|
-- |___|___||__|__||__||__|__|__|___._||____|__||_____|__|__|_____|
-- ---------------------------------------------------------------- --
-- https://gist.github.com/techtycho/47eb79735a5e5c1cab85d0f6cd869e9f#adding-to-keybindings
-- https://pastebin.com/XLa1Xkum
local effects = {
    { require("modules.effects.tagswitch"), "tagswitch" },
}
local M = {}

M.busy = false
M.timers = {}

M.instance = require("modules.effects.instance")

M.request_effect = function(name)
    for _, e in ipairs(effects) do
        if name == e[2] then
            return e[1]
        end
    end

    return false
end
return M
