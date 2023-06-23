-- add a list of buttons using :add_button to `widget`.
return function(widget, buttons)
    for _, button in ipairs(buttons) do
        widget:add_button(button)
    end
end
