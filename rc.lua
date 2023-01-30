pcall(require, "luarocks.loader")

require "awful.autofocus"
require("themes")
require ("utilities")
---@diagnostic disable-next-line: lowercase-global
utilities = require('utilities')
require "signal.global"
require "user_likes"
require "autostart"
require "configuration"
require "ui"
