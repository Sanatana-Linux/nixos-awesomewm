-- helpers/init.lua
local helpers = {}

-- Load helper modules and assign them to the `helpers` table.
for file in
    io.popen([[ls helpers/*.lua | sed 's/\.lua$//' ]])
        :read("*a")
        :gmatch("(.-)\n")
do
    helpers[file] = require("helpers." .. file)
end

return helpers
