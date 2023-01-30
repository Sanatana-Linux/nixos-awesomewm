--  _______ __          __
-- |_     _|  |--.----.|__|.-----.-----.-----.
--   |   | |     |   _||  ||-- __|  -__|     |
--   |___| |__|__|__|  |__||_____|_____|__|__|
-- ------------------------------------------------- --
-- NOTE: Area is divided into 1-3 even columns, then
-- new rows start after that.
-- https://github.com/ciiqr/thrizen
-- ------------------------------------------------- --
-- Grab environment we need
--
local pairs = pairs

local thrizen = {
    name = 'thrizen'
}

function thrizen.arrange(screen)
    local desiredColumns = 3
    -- ------------------------------------------------- --
    -- NOTE: Get the offset/size of this screen
    --
    local screenArea = screen.workarea
    -- ------------------------------------------------- --
    -- NOTE: Get the number of clients
    --
    local numClients = #screen.clients
    -- ------------------------------------------------- --
    -- NOTE: Determine the number of columns (min of numClients and desired columns)
    --
    local numColumns = numClients > desiredColumns and desiredColumns or numClients
    -- ------------------------------------------------- --
    -- NOTE: Determine the individual client width based on the number of columns
    --
    local targetWidth = screenArea.width / numColumns
    -- ------------------------------------------------- --
    -- NOTE: Determine the number of rows (must be a whole number)
    --
    local numRows = math.ceil(numClients / numColumns)
    -- ------------------------------------------------- --
    -- NOTE: Determine the individual client height based on the number of rows
    --
    local targetHeight = screenArea.height / numRows
    -- ------------------------------------------------- --
    -- NOTE: Iterate over the clients
    --
    for i, c in pairs(screen.clients) do
        -- ------------------------------------------------- --
        -- NOTE: Use the current index to determine the current column and row
        --
        local currentColumn = ((i - 1) % numColumns)
        local currentRow = math.floor((i - 1) / numColumns)

        local isSecondLastRow = currentRow == (numRows - 2)
        local hasRoomToFill = ((i - 1 + numColumns) >= numClients)
        local isDoubleHeight = hasRoomToFill and isSecondLastRow

        local clientOffsetX = currentColumn * targetWidth
        local clientOffsetY = currentRow * targetHeight

        screen.geometries[c] = {
            x = screenArea.x + clientOffsetX,
            y = screenArea.y + clientOffsetY,
            width = targetWidth,
            height = isDoubleHeight and 2 * targetHeight or targetHeight
        }
    end
end

return thrizen
