--
-- ╱╭━━━╮╱╭╮╭╮╭╮╱╭━━━╮╱╭━━━╮╱╭━━━╮╱╭━╮╭━╮╱╭━━━╮╱╭╮╭╮╭╮╱╭━╮╭━╮
-- ╱┃╭━╮┃╱┃┃┃┃┃┃╱┃╭━━╯╱┃╭━╮┃╱┃╭━╮┃╱┃┃╰╯┃┃╱┃╭━━╯╱┃┃┃┃┃┃╱┃┃╰╯┃┃
-- ╱┃┃╱┃┃╱┃┃┃┃┃┃╱┃╰━━╮╱┃╰━━╮╱┃┃╱┃┃╱┃╭╮╭╮┃╱┃╰━━╮╱┃┃┃┃┃┃╱┃╭╮╭╮┃
-- ╱┃╰━╯┃╱┃╰╯╰╯┃╱┃╭━━╯╱╰━━╮┃╱┃┃╱┃┃╱┃┃┃┃┃┃╱┃╭━━╯╱┃╰╯╰╯┃╱┃┃┃┃┃┃
-- ╱┃╭━╮┃╱╰╮╭╮╭╯╱┃╰━━╮╱┃╰━╯┃╱┃╰━╯┃╱┃┃┃┃┃┃╱┃╰━━╮╱╰╮╭╮╭╯╱┃┃┃┃┃┃
-- ╱╰╯╱╰╯╱╱╰╯╰╯╱╱╰━━━╯╱╰━━━╯╱╰━━━╯╱╰╯╰╯╰╯╱╰━━━╯╱╱╰╯╰╯╱╱╰╯╰╯╰╯
-- Add luarocks if available, if not, fail silently
pcall(require, "luarocks.loader")

-- Add lib/ for custom utilities and vendored modules.
local config_dir = os.getenv("HOME") .. "/.config/awesome"
package.path = config_dir
    .. "/lib/?.lua;"
    .. config_dir
    .. "/lib/?/init.lua;"
    .. package.path

-- Add lib directory to package.cpath for native modules
package.cpath = config_dir
    .. "/lib/?.so;"
    .. config_dir
    .. "/lib/?/?.so;"
    .. package.cpath

-- Load core functionality, keybindings, and UI
require("core")
require("bindings")
require("ui")
