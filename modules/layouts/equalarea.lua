--- Equal-area BSP layout.
-- Recursively divides the screen into equal-area rectangles using binary
-- space partitioning. Each client gets approximately equal space regardless
-- of count, with configurable master window count.
-- @module modules.layouts.equalarea
local config = {
    aspect_ratio_threshold = 1.3, -- Width/height ratio threshold for split direction
    max_masters = 1, -- Default number of master windows
    min_size = 50, -- Minimum client dimension in pixels
}

-- Import necessary modules
local math = math

-- Create the layout table
local equalarea = {}
equalarea.name = "equalarea"

--- Validate that a geometry has minimum size.
-- @tparam table g Geometry with `.width` and `.height`
-- @treturn boolean
-- @local
local function validate_geometry(g)
    return g and g.width >= config.min_size and g.height >= config.min_size
end

--- Calculate the optimal division ratio for a given number of clients.
-- Prefers balanced divisions (by 5, then 3, then 2) for visually pleasing
-- layouts rather than 1/N splits.
-- @tparam number num_clients Total clients in the range
-- @treturn number Size of the smaller division
-- @local
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

--- Recursively divide screen area among clients using BSP.
-- Base case: single client fills the area. Recursive case: split wide
-- areas vertically and tall areas horizontally.
-- @tparam table p Layout parameters object
-- @tparam table g Current geometry to subdivide
-- @tparam number low Start index in the client array
-- @tparam number high End index in the client array
-- @tparam table cls Array of client objects
-- @tparam number mwfact Master width factor (unused, for API compat)
-- @tparam number mcount Master count for client distribution
-- @local
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
                height = math.floor(g.height),
            }
        end
        return
    end

    -- Calculate client distribution
    local total_clients = high - low + 1
    local masters_in_range =
        math.max(0, math.min(mcount or config.max_masters, high) - low + 1)
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
        small_area.height =
            math.floor(g.height * small_division / total_clients)
        large_area.height = g.height - small_area.height
        large_area.x = g.x
        large_area.y = g.y + small_area.height
    end

    -- Recursively divide the areas for each subdivision
    if small_division > 0 then
        divide_area_recursive(
            p,
            small_area,
            low,
            low + small_division - 1,
            cls,
            mwfact,
            masters_in_small
        )
    end

    if large_division > 0 then
        divide_area_recursive(
            p,
            large_area,
            low + small_division,
            high,
            cls,
            mwfact,
            masters_in_large
        )
    end
end

--- Arrange clients using the equal-area BSP layout.
-- @tparam table p Layout parameters
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
    divide_area_recursive(
        p,
        workarea,
        1,
        #valid_clients,
        valid_clients,
        mwfact,
        mcount
    )
end

-- Return the layout object
return equalarea
