---@diagnostic disable: undefined-global
--[[
Arc chart widget for displaying circular progress indicators.
Wraps wibox.container.arcchart with animations and convenient API.
--]]

local wibox = require("wibox")
local beautiful = require("beautiful")
local animations = require("modules.animations")

local arc_chart = {}

function arc_chart.new(args)
    args = args or {}
    
    local ret = wibox.widget({
        widget = wibox.container.arcchart,
        values = { args.value or 0 },
        max_value = args.max_value or 100,
        min_value = args.min_value or 0,
        thickness = args.thickness or beautiful.xresources.apply_dpi(8),
        rounded_edge = args.rounded_edge ~= false,
        start_angle = args.start_angle or math.pi * 1.5, -- Start at top
        colors = { args.color or beautiful.accent_color or "#7aa2f7" },
        bg = args.bg_color or beautiful.bg_3 or "#3c3836",
        border_width = 0,
        {
            widget = wibox.container.margin,
            margins = args.margins or beautiful.xresources.apply_dpi(10),
            {
                layout = wibox.layout.align.vertical,
                expand = "none",
                nil,
                {
                    layout = wibox.layout.align.horizontal,
                    expand = "none",
                    nil,
                    {
                        layout = wibox.layout.fixed.vertical,
                        spacing = beautiful.xresources.apply_dpi(2),
                        {
                            widget = wibox.widget.textbox,
                            id = "percentage_text",
                            text = tostring(args.value or 0) .. "%",
                            font = args.font or beautiful.font_name .. " Bold 22",
                            align = "center",
                            valign = "center",
                        },
                        {
                            widget = wibox.widget.textbox,
                            id = "label_text", 
                            text = args.label or "",
                            font = args.label_font or beautiful.font_name .. " 16",
                            align = "center",
                            valign = "center",
                            opacity = 0.7,
                        },
                    },
                    nil,
                },
                nil,
            },
        },
    })

    -- Store references for easy access
    ret._percentage_text = ret:get_children_by_id("percentage_text")[1]
    ret._label_text = ret:get_children_by_id("label_text")[1] 
    ret._current_value = args.value or 0
    ret._animation = nil
    
    -- Animation settings
    ret._animate_duration = args.animate_duration or 0.3
    ret._animate_easing = args.animate_easing or "outQuad"

    function ret:set_value(value, animate)
        value = math.max(self.min_value, math.min(self.max_value, value or 0))
        
        if animate ~= false and self._animate_duration > 0 then
            -- Stop existing animation
            if self._animation then
                self._animation:stop()
            end
            
            local start_value = self._current_value
            self._animation = animations.animate({
                start = start_value,
                target = value,
                duration = self._animate_duration,
                easing = self._animate_easing,
                update = function(_, val)
                    local rounded_val = math.floor(val + 0.5)
                    self.values = { val }
                    self._percentage_text:set_text(tostring(rounded_val) .. "%")
                    self._current_value = val
                end,
                complete = function()
                    self._animation = nil
                end,
            })
        else
            -- Immediate update
            self.values = { value }
            self._percentage_text:set_text(tostring(math.floor(value + 0.5)) .. "%")
            self._current_value = value
        end
    end
    
    function ret:set_label(text)
        self._label_text:set_text(text or "")
    end
    
    function ret:set_color(color)
        self.colors = { color }
    end
    
    function ret:get_value()
        return self._current_value
    end

    return ret
end

return arc_chart