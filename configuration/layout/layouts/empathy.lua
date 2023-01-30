--  _______                        __   __
-- |    ___|.--------.-----.---.-.|  |_|  |--.--.--.
-- |    ___||        |  _  |  _  ||   _|     |  |  |
-- |_______||__|__|__|   __|___._||____|__|__|___  |
--                   |__|                    |_____|
-- ------------------------------------------------- --
-- NOTE: Adapted from the work of lilydjwg <lilydjwg@gmail.com>
-- https://github.com/lilydjwg/myawesomerc
-- --------------------- calls --------------------- --
local ipairs = ipairs
local math = math
local table = table
local buddylist_width = 295
-- local naughty = naughty

local function do_empathy(p)
    if #p.clients > 0 then
        -- ------------------------------------------------- --
        local cols = 3
        local area = {}
        area.height = p.workarea.height
        area.width = p.workarea.width
        area.x = p.workarea.x
        area.y = p.workarea.y

        -- ------------------------------------------------- --
        local cls = {}
        local buddylist_swap
        for k, c in ipairs(p.clients) do
            if c.name ~= 'Empathy' and c.name ~= 'Contact List' and c.name ~= 'Empathy' then
                table.insert(cls, c)
            else
                if k ~= 1 then
                    buddylist_swap = c
                end
                c:geometry(
                    {
                        width = buddylist_width - 2,
                        height = area.height - 3,
                        x = area.x,
                        y = area.y
                    }
                )
                cols = cols - 1
                area.x = area.x + buddylist_width
                area.width = area.width - buddylist_width
            end
        end
        -- ------------------------------------------------- --
        local rows = math.ceil(#cls / cols)
        local cols = math.ceil(#cls / rows)
        local aligned = (rows - 1) * cols
        local col = 1
        local row = 1

        -- ------------------------------------------------- --
        for k, c in ipairs(cls) do
            local g = {}
            g.height = area.height / rows
            if k <= aligned then
                g.width = area.width / cols
            else
                g.width = area.width / (#cls - (rows - 1) * cols)
            end

            g.x = area.x + (col - 1) * g.width
            g.y = area.y + (row - 1) * g.height
            if row == rows then
                g.height = g.height - 3
            else
                g.height = g.height - 2
            end
            g.width = g.width - 2

            if col == cols then
                col = 1
                row = row + 1
            else
                col = col + 1
            end

            c:geometry(g)
        end
        if #cls > 0 and buddylist_swap then
            buddylist_swap:swap(cls[1])
        end
    end
end

local empathy = {}
empathy.name = 'empathy'

-- ------------------------------------------------- --
-- NOTE: The screen to arrange.

function empathy.arrange(p)
    return do_empathy(p)
end

return empathy
