-- NOTE: Area is divided into 1-3 even columns, then
-- new rows start after that.
-- https://github.com/ciiqr/thrizen
--   +---------------------------------------------------------------+

-- Import necessary modules
local pairs = pairs
local math = math

-- Create a table for the custom layout
local thrizen = { name = "thrizen" }

-- Function to arrange clients in the 'thrizen' layout
function thrizen.arrange(screen)
    -- Set the desired number of columns
    local desiredColumns = 3

    -- Get the work area dimensions of the screen
    local screenArea = screen.workarea

    -- Get the number of clients on the screen
    local numClients = #screen.clients

    -- Determine the number of columns (minimum of numClients and desired columns)
    local numColumns = math.min(numClients, desiredColumns)

    -- Determine the individual client width based on the number of columns
    local targetWidth = screenArea.width / numColumns

    -- Determine the number of rows (must be a whole number)
    local numRows = math.ceil(numClients / numColumns)

    -- Determine the individual client height based on the number of rows
    local targetHeight = screenArea.height / numRows

    -- Iterate over the clients
    for i, c in pairs(screen.clients) do
        -- Use the current index to determine the current column and row
        local currentColumn = (i - 1) % numColumns
        local currentRow = math.floor((i - 1) / numColumns)

        -- Check if it's the second-to-last row and there is room to fill
        local isSecondLastRow = currentRow == (numRows - 2)
        local hasRoomToFill = (i - 1 + numColumns) >= numClients
        local isDoubleHeight = hasRoomToFill and isSecondLastRow

        -- Calculate client offset based on column and row
        local clientOffsetX = currentColumn * targetWidth
        local clientOffsetY = currentRow * targetHeight

        -- Set the geometry for the client
        screen.geometries[c] = {
            x = screenArea.x + clientOffsetX,
            y = screenArea.y + clientOffsetY,
            width = targetWidth,
            height = isDoubleHeight and 2 * targetHeight or targetHeight,
        }
    end
end

-- Return the 'thrizen' layout object
return thrizen
