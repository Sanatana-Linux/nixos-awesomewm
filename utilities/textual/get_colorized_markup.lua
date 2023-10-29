--  _______         __     ______         __              __                 __
-- |     __|.-----.|  |_  |      |.-----.|  |.-----.----.|__|.-----.-----.--|  |
-- |    |  ||  -__||   _| |   ---||  _  ||  ||  _  |   _||  ||-- __|  -__|  _  |
-- |_______||_____||____| |______||_____||__||_____|__|  |__||_____|_____|_____|
--
--                     _______              __
--                    |    |  |.---.-.----.|  |--.--.--.-----.
--                    |       ||  _  |   _||    <|  |  |  _  |
--                    |__|____||___._|__|  |__|__|_____|   __|
--                                                     |__|
--   +---------------------------------------------------------------+
-- @param content widget
-- @param fg string
-- @return widget colorized

local beautiful = require("beautiful")

return function(content, fg)
    fg = fg or beautiful.lessgrey
    content = content or ""

    return '<span foreground="' .. fg .. '">' .. content .. "</span>"
end
