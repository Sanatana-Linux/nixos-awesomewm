local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- Common UI constants to reduce hardcoded values across the codebase
local ui_constants = {
    SPACING = {
        TINY = dpi(2),
        SMALL = dpi(6), 
        MEDIUM = dpi(8),
        LARGE = dpi(12),
        XLARGE = dpi(15),
        XXLARGE = dpi(20),
    },
    RADIUS = {
        SMALL = 8,
        MEDIUM = 10,
        LARGE = 18,
        XLARGE = 20,
    },
    ANIMATION = {
        DURATION_SHORT = 0.3,
        EASING_DEFAULT = "quadratic",
        SLIDE_OFFSET = dpi(20),
    },
    BUTTON = {
        BAR_SIZE = dpi(32),
        ICON_SIZE = dpi(20),
        SMALL_ICON_SIZE = dpi(16),
    },
    BORDER = {
        THIN = dpi(1),
        MEDIUM = dpi(1.5),
    },
    COLORS = {
        WHITE = "#FFFFFF",
        TRANSPARENT_BLACK = "#00000044",
        SEMI_TRANSPARENT_BLACK = "#00000088",
    },
}

return ui_constants