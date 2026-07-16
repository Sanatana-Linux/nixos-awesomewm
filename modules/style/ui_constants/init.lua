--- Shared UI dimension and color constants.
-- Imported throughout the codebase (`require("modules.style.ui_constants")`) to
-- keep spacing / radius / animation tuning in one place. Constants marked
-- `dpi(...)` are scaled by `beautiful.xresources.apply_dpi` at load time;
-- raw numbers (in `RADIUS`) are not DPI-scaled and represent a stable
-- visual proportion.
-- @module modules.ui_constants

local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- Common UI constants to reduce hardcoded values across the codebase
-- @field SPACING table Pixel spacing tokens (TINY → XXLARGE), DPI-scaled
-- @field RADIUS table Corner-radius tokens (SMALL → XLARGE), raw pixels
-- @field ANIMATION table Animation timing & easing defaults
-- @field BUTTON table Standard button size / icon size
-- @field BORDER table Border-width tokens (THIN, MEDIUM), DPI-scaled
-- @field COLORS table Reusable alpha-suffixed colors
-- @table ui_constants
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
