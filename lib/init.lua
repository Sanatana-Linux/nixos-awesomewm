--- Aggregator for vendored libraries.
-- Exposes `lib.inspect`, `lib.json`, and `lib.dbus_proxy`.
-- Hand-rolled utility functions have been split into `lib.util`.
-- @module lib

local lib = {}

lib.inspect = require("lib.inspect")
lib.json = require("lib.json")
lib.dbus_proxy = require("lib.dbus_proxy")

return lib
