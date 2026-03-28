pcall(require, "luarocks.loader")

-- Add upstream directory to package.path to use modified builtin libraries
local config_dir = os.getenv("HOME") .. "/.config/awesome"
package.path = config_dir .. "/upstream/?.lua;" .. config_dir .. "/upstream/?/init.lua;" .. package.path

-- Load core functionality and UI
require("core")
require("ui")
