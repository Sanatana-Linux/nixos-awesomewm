-- Thrizen Layout - 3-column grid layout with intelligent row distribution
-- NOTE: Area is divided into 1-3 even columns, then new rows start after that.
-- Based on: https://github.com/ciiqr/thrizen
--
-- Layout behavior:
-- - Divides screen into up to 3 columns
-- - Distributes clients evenly across columns and rows
-- - Last client in second-to-last row gets double height if space available
--
-- Configuration:
local config = {
    max_columns = 3,    -- Maximum number of columns (1-3)
    min_width = 200,    -- Minimum client width in pixels
}

-- Import necessary modules
local math = math
local pairs = pairs

-- Create the layout table
local thrizen = { name = "thrizen" }

-- Helper function to validate inputs
local function validate_inputs(p)
    if not p then
        return false, "No layout parameters provided"
    end
    if not p.clients or #p.clients == 0 then
        return false, "No clients to arrange"
    end
    if not p.workarea then
        return false, "No workarea defined"
    end
    return true, nil
end

-- Helper function to calculate layout dimensions
local function calculate_dimensions(workarea, num_clients)
    -- Determine the number of columns (minimum of num_clients and max_columns)
    local num_columns = math.min(num_clients, config.max_columns)
    
    -- Ensure minimum width constraints are met
    local proposed_width = workarea.width / num_columns
    if proposed_width < config.min_width and num_columns > 1 then
        num_columns = math.max(1, math.floor(workarea.width / config.min_width))
    end
    
    -- Calculate individual client dimensions
    local client_width = workarea.width / num_columns
    local num_rows = math.ceil(num_clients / num_columns)
    local client_height = workarea.height / num_rows
    
    return {
        columns = num_columns,
        rows = num_rows,
        width = client_width,
        height = client_height
    }
end

-- Helper function to check if client should get double height
local function should_double_height(client_index, dimensions, num_clients)
    local current_row = math.floor((client_index - 1) / dimensions.columns)
    local is_second_last_row = current_row == (dimensions.rows - 2)
    local has_room_to_fill = (client_index - 1 + dimensions.columns) >= num_clients
    
    return has_room_to_fill and is_second_last_row and dimensions.rows > 1
end

-- Main arrangement function
function thrizen.arrange(p)
    -- Validate inputs
    local valid, error_msg = validate_inputs(p)
    if not valid then
        -- Silently return if no valid arrangement can be made
        return
    end
    
    local workarea = p.workarea
    local clients = p.clients
    local num_clients = #clients
    
    -- Calculate layout dimensions
    local dimensions = calculate_dimensions(workarea, num_clients)
    
    -- Arrange each client
    for i, c in pairs(clients) do
        -- Skip invalid clients
        if not c or c.minimized or not c.valid then
            goto continue
        end
        
        -- Calculate grid position (0-based for math, then adjust)
        local current_column = (i - 1) % dimensions.columns
        local current_row = math.floor((i - 1) / dimensions.columns)
        
        -- Calculate client position
        local client_x = workarea.x + (current_column * dimensions.width)
        local client_y = workarea.y + (current_row * dimensions.height)
        
        -- Determine client height (double height for special case)
        local client_height = dimensions.height
        if should_double_height(i, dimensions, num_clients) then
            client_height = 2 * dimensions.height
        end
        
        -- Set client geometry through the proper AwesomeWM parameter structure
        p.geometries[c] = {
            x = math.floor(client_x),
            y = math.floor(client_y),
            width = math.floor(dimensions.width),
            height = math.floor(client_height),
        }
        
        ::continue::
    end
end

-- Return the layout object
return thrizen
