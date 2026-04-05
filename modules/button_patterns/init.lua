local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local gcolor = require("gears.color")
local ui_constants = require("modules.ui_constants")
local shapes = require("modules.shapes")
local hover_button = require("modules.hover_button")

-- Common button patterns and styles
local button_patterns = {}

-- Standard bar button (used in launcher, control panel, etc.)
function button_patterns.bar_button(args)
    args = args or {}
    
    return wibox.widget({
        widget = wibox.container.background,
        forced_width = args.width or ui_constants.BUTTON.BAR_SIZE,
        forced_height = args.height or ui_constants.BUTTON.BAR_SIZE,
        bg = args.bg or beautiful.bg_gradient_button,
        shape = shapes.rrect(args.radius or ui_constants.RADIUS.MEDIUM),
        buttons = args.buttons or {},
        {
            widget = wibox.container.margin,
            margins = args.margins or ui_constants.SPACING.TINY,
            args.child or args[1],
        },
    })
end

-- Icon button with hover effects
function button_patterns.icon_button(args)
    args = args or {}
    
    local icon_widget = {
        widget = wibox.widget.imagebox,
        image = args.icon and gcolor.recolor_image(args.icon, args.icon_color or beautiful.fg) or nil,
        resize = true,
        forced_width = args.icon_size or ui_constants.BUTTON.ICON_SIZE,
        forced_height = args.icon_size or ui_constants.BUTTON.ICON_SIZE,
    }
    
    if args.use_hover_button ~= false then
        return hover_button({
            bg_normal = args.bg_normal or beautiful.bg,
            bg_hover = args.bg_hover or beautiful.bg_gradient_button_alt,
            fg_normal = args.fg_normal or beautiful.fg,
            fg_hover = args.fg_hover or beautiful.fg,
            shape = shapes.rrect(args.radius or ui_constants.RADIUS.MEDIUM),
            margins = args.margins or ui_constants.SPACING.MEDIUM,
            buttons = args.buttons,
            child_widget = icon_widget,
        })
    else
        return button_patterns.bar_button({
            width = args.width,
            height = args.height,
            bg = args.bg_normal,
            radius = args.radius,
            margins = args.margins,
            buttons = args.buttons,
            child = icon_widget,
        })
    end
end

-- Text button with consistent styling
function button_patterns.text_button(args)
    args = args or {}
    
    return hover_button({
        label = args.label or args.text,
        bg_normal = args.bg_normal or beautiful.bg_alt,
        bg_hover = args.bg_hover or beautiful.bg_urg,
        fg_normal = args.fg_normal or beautiful.fg,
        fg_hover = args.fg_hover or beautiful.fg,
        shape = shapes.rrect(args.radius or ui_constants.RADIUS.MEDIUM),
        margins = args.margins or {
            left = ui_constants.SPACING.LARGE,
            right = ui_constants.SPACING.LARGE,
            top = ui_constants.SPACING.MEDIUM,
            bottom = ui_constants.SPACING.MEDIUM,
        },
        buttons = args.buttons,
    })
end

-- Close button (red X button pattern with red gradient hover effect)
function button_patterns.close_button(args)
    args = args or {}
    
    local icon_widget = {
        widget = wibox.widget.imagebox,
        image = args.icon and gcolor.recolor_image(args.icon, args.icon_color or beautiful.red) or nil,
        resize = true,
        forced_width = args.icon_size or ui_constants.BUTTON.SMALL_ICON_SIZE,
        forced_height = args.icon_size or ui_constants.BUTTON.SMALL_ICON_SIZE,
    }
    
    if args.use_hover_button ~= false then
        return hover_button({
            bg_normal = args.bg_normal or "transparent",
            -- Special red gradient hover effect like power menu toggle
            bg_hover = args.bg_hover or ("linear:0,0:0,32:0," .. beautiful.red .. ":1," .. "#b61442"),
            fg_normal = args.fg_normal or beautiful.red,
            fg_hover = args.fg_hover or beautiful.bg, -- White icon on hover
            icon_normal_color = args.icon_normal_color or beautiful.red,
            icon_hover_color = args.icon_hover_color or beautiful.bg, -- White icon on hover
            shape = shapes.rrect(args.radius or ui_constants.RADIUS.MEDIUM),
            margins = args.margins or ui_constants.SPACING.MEDIUM,
            buttons = args.buttons,
            child_widget = icon_widget,
        })
    else
        return button_patterns.bar_button({
            width = args.width,
            height = args.height,
            bg = args.bg_normal,
            radius = args.radius,
            margins = args.margins,
            buttons = args.buttons,
            child = icon_widget,
        })
    end
end

-- Add hover effects to existing widgets
function button_patterns.add_hover_effect(widget, bg_normal, bg_hover)
    bg_normal = bg_normal or beautiful.bg_gradient_button
    bg_hover = bg_hover or beautiful.bg_gradient_button_alt
    
    widget:set_bg(bg_normal)
    
    widget:connect_signal("mouse::enter", function(w)
        w:set_bg(bg_hover)
    end)
    
    widget:connect_signal("mouse::leave", function(w)
        w:set_bg(bg_normal)
    end)
    
    return widget
end

return button_patterns