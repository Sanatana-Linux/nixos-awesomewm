--
-- ╱╭━━━╮╱╭╮╭╮╭╮╱╭━━━╮╱╭━━━╮╱╭━━━╮╱╭━╮╭━╮╱╭━━━╮╱╭╮╭╮╭╮╱╭━╮╭━╮
-- ╱┃╭━╮┃╱┃┃┃┃┃┃╱┃╭━━╯╱┃╭━╮┃╱┃╭━╮┃╱┃┃╰╯┃┃╱┃╭━━╯╱┃┃┃┃┃┃╱┃┃╰╯┃┃
-- ╱┃┃╱┃┃╱┃┃┃┃┃┃╱┃╰━━╮╱┃╰━━╮╱┃┃╱┃┃╱┃╭╮╭╮┃╱┃╰━━╮╱┃┃┃┃┃┃╱┃╭╮╭╮┃
-- ╱┃╰━╯┃╱┃╰╯╰╯┃╱┃╭━━╯╱╰━━╮┃╱┃┃╱┃┃╱┃┃┃┃┃┃╱┃╭━━╯╱┃╰╯╰╯┃╱┃┃┃┃┃┃
-- ╱┃╭━╮┃╱╰╮╭╮╭╯╱┃╰━━╮╱┃╰━╯┃╱┃╰━╯┃╱┃┃┃┃┃┃╱┃╰━━╮╱╰╮╭╮╭╯╱┃┃┃┃┃┃
-- ╱╰╯╱╰╯╱╱╰╯╰╯╱╱╰━━━╯╱╰━━━╯╱╰━━━╯╱╰╯╰╯╰╯╱╰━━━╯╱╱╰╯╰╯╱╱╰╯╰╯╰╯
-- Add luarocks if available, if not, fail silently
pcall(require, "luarocks.loader")

-- Add upstream directory to package.path to use modified builtin libraries
local config_dir = os.getenv("HOME") .. "/.config/awesome"
package.path = config_dir
.. "/upstream/?.lua;"
.. config_dir
.. "/upstream/?/init.lua;"
.. package.path

-- Add lib directory to package.cpath for native modules
package.cpath = config_dir
.. "/lib/?.so;"
.. config_dir
.. "/lib/?/?.so;"
.. package.cpath

-- Load core functionality and UI
require("configuration")
require("ui")
