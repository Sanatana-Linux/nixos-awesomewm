--[[

     Licensed under GNU General Public License v2
      * (c) 2014,      projektile
      * (c) 2013,      Luca CPZ
      * (c) 2010-2012, Peter Hofmann

--]]

local floor = math.floor
local screen = screen

-- Define the cascade layout configuration
local cascade = {
    name = "cascade",
    nmaster = 0,
    offset_x = 32,
    offset_y = 8,
    tile = {
        name = "cascadetile",
        nmaster = 0,
        ncol = 0,
        mwfact = 0,
        offset_x = 8,
        offset_y = 32,
        extra_padding = 0,
    },
}

-- Function to perform the cascade layout
local function do_cascade(p, tiling)
    local t = p.tag or screen[p.screen].selected_tag
    local wa = p.workarea
    local cls = p.clients

    -- Check if there are no clients
    if #cls == 0 then
        return
    end

    if not tiling then
        -- Cascade windows.

        local num_c = cascade.nmaster > 0 and cascade.nmaster or t.master_count
        local how_many = (#cls >= num_c and #cls) or num_c

        local current_offset_x = cascade.offset_x * (how_many - 1)
        local current_offset_y = cascade.offset_y * (how_many - 1)

        -- Iterate through clients and set their geometries
        for i = 1, #cls do
            local c = cls[i]
            local g = {}

            g.x = wa.x + (how_many - i) * cascade.offset_x
            g.y = wa.y + (i - 1) * cascade.offset_y
            g.width = wa.width - current_offset_x
            g.height = wa.height - current_offset_y

            -- Ensure minimum size
            g.width = g.width < 1 and 1 or g.width
            g.height = g.height < 1 and 1 or g.height

            p.geometries[c] = g
        end
    else
        -- Layout with one fixed column for a master window and slave column for others.

        local mwfact = cascade.tile.mwfact > 0 and cascade.tile.mwfact
            or t.master_width_factor
        local overlap_main = cascade.tile.ncol > 0 and cascade.tile.ncol
            or t.column_count
        local num_c = cascade.tile.nmaster > 0 and cascade.tile.nmaster
            or t.master_count

        local how_many = (#cls - 1 >= num_c and (#cls - 1)) or num_c

        local current_offset_x = cascade.tile.offset_x * (how_many - 1)
        local current_offset_y = cascade.tile.offset_y * (how_many - 1)

        if #cls <= 0 then
            return
        end

        local c = cls[1]
        local g = {}
        local mainwid = floor(wa.width * mwfact)
        local slavewid = wa.width - mainwid

        g.width = overlap_main == 1 and wa.width - cascade.tile.extra_padding
            or mainwid
        g.height = wa.height
        g.x, g.y = wa.x, wa.y

        -- Ensure minimum size
        g.width = g.width < 1 and 1 or g.width
        g.height = g.height < 1 and 1 or g.height

        p.geometries[c] = g

        -- Set geometries for remaining clients in the slave column
        if #cls > 1 then
            for i = 2, #cls do
                c = cls[i]
                g = {}

                g.width = slavewid - current_offset_x
                g.height = wa.height - current_offset_y
                g.x = wa.x
                    + mainwid
                    + (how_many - (i - 1)) * cascade.tile.offset_x
                g.y = wa.y + (i - 2) * cascade.tile.offset_y

                -- Ensure minimum size
                g.width = g.width < 1 and 1 or g.width
                g.height = g.height < 1 and 1 or g.height

                p.geometries[c] = g
            end
        end
    end
end

-- Function to arrange clients using the cascade layout with tiling
function cascade.tile.arrange(p)
    return do_cascade(p, true)
end

-- Function to arrange clients using the cascade layout without tiling
function cascade.arrange(p)
    return do_cascade(p, false)
end

return cascade
