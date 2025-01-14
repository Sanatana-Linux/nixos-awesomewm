local json = require("mods.json")
local helpers = require("helpers")
local gfs = require("gears.filesystem")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local M = {}

M.defaultData = {
    colorscheme = "monokaiprospectrum",
    gaps = dpi(10),
    iconTheme = "/run/current-system/sw/share/icons/Reversal-dark",
    openWeatherApi = "KEY_HERE",
    showDesktopIcons = true,
    pfp = "/home/"
        ---@diagnostic disable-next-line: param-type-mismatch
        .. string.gsub(os.getenv("USER"), "^%l", string.lower)
        .. "/.config/awesome/theme/assets/nixos.svg",
    wallpaper = "colorful",
}

M.path = gfs.get_cache_dir() .. "json/settings.json"

function M:generate()
    if not helpers.file_exists(self.path) then
        local w = assert(io.open(self.path, "w"))
        w:write(json.encode(self.defaultData))
        w:close()
        M.settings = self.defaultData
    else
        local r = assert(io.open(self.path, "rb"))
        local t = r:read("*all")
        r:close()
        local settings = json.decode(t)
        M.settings = settings
    end

    if not helpers.file_exists(gfs.get_cache_dir() .. "lock/lock.jpg") then
        os.execute("mkdir -p ~/.cache/awesome/lock")
    end
end

return M
