pcall(require, "luarocks.loader")

-- Start garbage collection service
local gc_service = require("service.garbage_collection")
gc_service.start()

-- Load core functionality and UI
require("core")
require("ui")
