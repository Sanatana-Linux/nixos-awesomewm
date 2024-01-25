--     _______     __     __   ______         __   __
--    |   _   |.--|  |.--|  | |   __ \.--.--.|  |_|  |_.-----.-----.-----.
--    |       ||  _  ||  _  | |   __ <|  |  ||   _|   _|  _  |     |__ --|
--    |___|___||_____||_____| |______/|_____||____|____|_____|__|__|_____|
--
--   +---------------------------------------------------------------+
-- add a list of buttons using :add_button to `widget`.
return function(widget, buttons)
    for _, button in ipairs(buttons) do
        widget:add_button(button)
    end
end
