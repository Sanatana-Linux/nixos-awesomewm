-- EqualArea Layout - Recursive area division with equal client areas
-- 
-- This layout uses a recursive binary space partitioning algorithm to divide
-- the screen into roughly equal areas for each client. The algorithm:
--
-- 1. Recursively divides the available space into smaller and larger sections
-- 2. Distributes master and slave clients across these sections
-- 3. Uses a 1.3 aspect ratio threshold to decide horizontal vs vertical splits
-- 4. Optimizes for various client counts with special handling for divisible numbers
--
-- Mathematical approach:
-- - For n clients, finds optimal subdivision ratios
-- - Prefers divisions by 5, 3, or 2 in that order for balanced layouts  
-- - Uses master-slave distribution with configurable master count
--
-- Configuration:
local config = {
    aspect_ratio_threshold = 1.3,  -- Width/height ratio threshold for split direction
    max_masters = 1,               -- Default number of master windows
    min_size = 50,                 -- Minimum client dimension in pixels
}

-- Import necessary modules
local math = math

-- Create the layout table  
local equalarea = {}
equalarea.name = "equalarea"

-- Helper function to validate geometry bounds
local function validate_geometry(g)
    return g and g.width >= config.min_size and g.height >= config.min_size
end

-- Calculate optimal division ratio for a given number of clients
-- Returns the smaller division size, optimizing for visual balance
local function calculate_division_ratio(num_clients)
    if num_clients <= 1 then
        return num_clients
    end
    
    -- Prefer divisions that create balanced layouts
    -- Priority: divisible by 5, then 3, then 2
    if num_clients > 5 and (num_clients % 5) == 0 then
        return math.floor(num_clients / 5)
    elseif (num_clients % 3) == 0 then
        return math.floor(num_clients / 3)
    else
        return math.floor(num_clients / 2)
    end
end

-- Recursive function to divide screen area among clients using binary space partitioning
-- @param p: Layout parameters from AwesomeWM
-- @param g: Current geometry area to divide  
-- @param low: Starting index in client array
-- @param high: Ending index in client array
-- @param cls: Array of client objects
-- @param mwfact: Master width factor (unused in current implementation)
-- @param mcount: Number of master windows
local function divide_area_recursive(p, g, low, high, cls, mwfact, mcount)
    -- Input validation
    if not g or not validate_geometry(g) then
        return
    end
    
    if low == high then
        -- Base case: single client gets the entire area
        if cls[low] and cls[low].valid then
            p.geometries[cls[low]] = {
                x = math.floor(g.x),
                y = math.floor(g.y), 
                width = math.floor(g.width),
                height = math.floor(g.height)
            }
        end
        return
    end

    -- Calculate client distribution
    local total_clients = high - low + 1
    local masters_in_range = math.max(0, math.min(mcount or config.max_masters, high) - low + 1)
    local slaves_in_range = total_clients - masters_in_range

    -- Calculate division sizes using optimized ratio
    local small_division = calculate_division_ratio(total_clients)  
    local large_division = total_clients - small_division

    -- Distribute masters between divisions
    local masters_in_small = math.min(masters_in_range, small_division)
    local masters_in_large = masters_in_range - masters_in_small

    -- Create geometries for the two subdivisions
    local small_area = { x = g.x, y = g.y }
    local large_area = {}

    -- Choose split direction based on aspect ratio
    -- Wide areas split vertically, tall areas split horizontally
    local is_wide = g.width > (g.height * config.aspect_ratio_threshold)
    
    if is_wide then
        -- Split vertically (side by side)
        small_area.height = g.height
        large_area.height = g.height
        small_area.width = math.floor(g.width * small_division / total_clients)
        large_area.width = g.width - small_area.width
        large_area.x = g.x + small_area.width  
        large_area.y = g.y
    else
        -- Split horizontally (top and bottom)
        small_area.width = g.width
        large_area.width = g.width  
        small_area.height = math.floor(g.height * small_division / total_clients)
        large_area.height = g.height - small_area.height
        large_area.x = g.x
        large_area.y = g.y + small_area.height
    end

    -- Recursively divide the areas for each subdivision
    if small_division > 0 then
        divide_area_recursive(p, small_area, low, low + small_division - 1, cls, mwfact, masters_in_small)
    end
    
    if large_division > 0 then 
        divide_area_recursive(p, large_area, low + small_division, high, cls, mwfact, masters_in_large)
    end
end

-- Main arrangement function for the equalarea layout
function equalarea.arrange(p)
    -- Validate input parameters
    if not p or not p.clients or #p.clients == 0 then
        return
    end
    
    if not p.workarea then
        return  
    end

    -- Get layout parameters
    local clients = p.clients
    local workarea = p.workarea  
    local num_clients = #clients
    
    -- Get tag-specific settings or use defaults
    local tag = p.tag or (clients[1] and clients[1].screen.selected_tag)
    local mwfact = tag and tag.master_width_factor or 0.6
    local mcount = tag and tag.master_count or config.max_masters

    -- Filter out invalid clients
    local valid_clients = {}
    for _, c in ipairs(clients) do
        if c and c.valid and not c.minimized then
            table.insert(valid_clients, c)
        end
    end
    
    if #valid_clients == 0 then
        return
    end

    -- Start recursive division with full workarea
    divide_area_recursive(p, workarea, 1, #valid_clients, valid_clients, mwfact, mcount)
end

-- Return the layout object
return equalarea