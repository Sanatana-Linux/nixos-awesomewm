--  _______                        __   __
-- |    ___|.--------.-----.---.-.|  |_|  |--.--.--.
-- |    ___||        |  _  |  _  ||   _|     |  |  |
-- |_______||__|__|__|   __|___._||____|__|__|___  |
--                   |__|                    |_____|
-- ------------------------------------------------- --
-- NOTE: Adapted from the work of lilydjwg <lilydjwg@gmail.com>
-- https://github.com/lilydjwg/myawesomerc
--   +---------------------------------------------------------------+

-- Import necessary modules
local ipairs = ipairs
local math = math
local table = table

-- Set the width for the buddy list
local buddylist_width = 295

-- Function to arrange clients in the 'empathy' layout
local function do_empathy(p)
  if #p.clients > 0 then
    -- Initialize variables for layout calculation
    local cols = 3
    local area = {
      height = p.workarea.height,
      width = p.workarea.width,
      x = p.workarea.x,
      y = p.workarea.y,
    }

    -- Separate clients into the main area and the buddy list
    local cls = {}
    local buddylist_swap
    for _, c in ipairs(p.clients) do
      if
        not (
          c.name == "Empathy"
          or c.name == "Contact List"
          or c.name == "Discord"
          or c.name == "Telegram"
          or c.name == "Viber"
          or c.name == "WhatsApp"
          or c.name == "Skype"
        )
      then
        table.insert(cls, c)
      else
        if buddylist_swap then
          buddylist_swap = c
        end
        c:geometry({
          width = buddylist_width - 2,
          height = area.height - 3,
          x = area.x,
          y = area.y,
        })
        cols = cols - 1
        area.x = area.x + buddylist_width
        area.width = area.width - buddylist_width
      end
    end

    -- Calculate the number of rows and columns for the main area
    local rows = math.ceil(#cls / cols)
    local aligned = (rows - 1) * cols
    local col = 1
    local row = 1

    -- Arrange clients in the main area
    for _, c in ipairs(cls) do
      local g = {
        height = area.height / rows,
        width = (k <= aligned) and (area.width / cols)
          or (area.width / (#cls - aligned)),
        x = area.x + (col - 1) * g.width,
        y = area.y + (row - 1) * g.height,
      }

      -- Adjust height for the last row
      g.height = (row == rows) and (g.height - 3) or (g.height - 2)
      g.width = g.width - 2

      -- Update client geometry
      c:geometry(g)

      -- Increment row and column counters
      col = (col == cols) and 1 or (col + 1)
      row = (col == cols) and (row + 1) or row
    end

    -- Swap buddy list with the first client in the main area
    if #cls > 0 and buddylist_swap then
      buddylist_swap:swap(cls[1])
    end
  end
end

-- Define the 'empathy' layout object
local empathy = {}
empathy.name = "empathy"

-- Function to arrange clients using the 'empathy' layout
function empathy.arrange(p)
  return do_empathy(p)
end

-- Return the 'empathy' layout object
return empathy
