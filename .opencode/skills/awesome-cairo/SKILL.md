---
name: awesome-cairo
description:
  Work with Cairo surfaces, custom widget drawing, and theme asset generation
  in this AwesomeWM config. Use when creating painted surfaces, custom widget
  :draw() methods, gradient backgrounds, icon recoloring, shape functions,
  or cropping/transforming images.
---

# AwesomeWM Cairo Surface & Drawing Guide

This skill encodes the exact Cairo (`lgi.cairo`) patterns used across this
AwesomeWM config — from theme asset generation and surface cropping to custom
widget drawing and gradient backgrounds.

## When to Use

- Creating or modifying a Cairo surface (e.g., generating icon images, cropping
  a surface, compositing multiple layers)
- Implementing a custom widget with a `:draw(cr, width, height)` method
- Working with gradient backgrounds (linear, radial) in theme or UI components
- Recoloring icons via `gears.color.recolor_image`
- Building shape functions like `modules/shapes/init.lua`
- Generating theme assets via the `theme_assets.lua` pattern
- Debugging drawing glitches in container backgrounds, borders, or client shapes

## Architecture

All Cairo access goes through `lgi` (Lua GObject introspection):

```lua
local cairo = require("lgi").cairo
```

Key modules in this codebase that use Cairo directly:

| Module | File | Purpose |
|--------|------|---------|
| `modules/shapes` | `modules/shapes/init.lua` | Shape function factories (rrect, circle, squircle) |
| `modules/crop_surface` | `modules/crop_surface/init.lua` | Aspect-ratio cropping of Cairo surfaces |
| `upstream/beautiful/theme_assets` | `upstream/beautiful/theme_assets.lua` | Generating taglist squares, AwesomeWM name, layout icons |
| `upstream/gears/surface` | `upstream/gears/surface.lua` | Surface loading, saving, scaling, compositing |
| `upstream/gears/color` | `upstream/gears/color.lua` | Color parsing, gradient creation, icon recoloring |
| `upstream/wibox/drawable` | `upstream/wibox/drawable.lua` | Main widget drawing pipeline (background, wallpaper, dirty regions) |
| `upstream/wibox/hierarchy` | `upstream/wibox/hierarchy.lua` | Per-widget hierarchy drawing with groups and transforms |
| `upstream/wibox/container/background` | `upstream/background.lua` | Background rendering with shape clipping, gradients, masks |
| `modules/layouts/navigator` | `modules/layouts/navigator.lua` | Custom widget with `:draw()` method painting gradients + shapes |

---

## 1. Basic Surface Creation

### Creating a blank surface and drawing on it

```lua
local cairo = require("lgi").cairo

-- Create an ARGB32 surface (most common — supports transparency)
local img = cairo.ImageSurface(cairo.Format.ARGB32, width, height)

-- Create a 1-bit alpha mask surface
local mask = cairo.ImageSurface(cairo.Format.A1, width, height)

-- Create an RGB-only surface (no alpha — slightly faster)
local rgb = cairo.ImageSurface(cairo.Format.RGB24, width, height)

-- Get a Cairo context for drawing on the surface
local cr = cairo.Context(img)
```

### Surface from existing data (used in naughty notifications)

```lua
-- Create surface from raw pixel data
local stride = cairo.Format.stride_for_width(format, w)
local surf = cairo.ImageSurface.create_for_data(pixels, format, w, h, stride)
```

### Loading surfaces from files

```lua
local surface = require("gears.surface")

-- Load a surface silently (returns nil on failure)
local surf = surface.load_silently(path, false)

-- Load with error handling
local ok, surf = pcall(surface.load_silently, path, false)
```

### Getting surface properties

```lua
-- Get size
local w, h = surface.get_size(surf)

-- Get width/height separately (they're also surface properties in newer API)
```

---

## 2. Drawing Operations

### Fills and Strokes

```lua
-- Fill the current path with the current source color
cr:fill()

-- Stroke (outline) the current path
cr:stroke()

-- Fill and keep the path for further manipulation
cr:fill_preserve()

-- Paint the entire surface area with the current source
cr:paint()

-- Paint with alpha/opacity
cr:paint_with_alpha(0.5)
```

### Rectangles

```lua
-- Draw a rectangle at (x, y) with given width and height
cr:rectangle(x, y, width, height)
cr:fill()  -- or cr:stroke()

-- Example: filled background rect
cr:set_source(color("#ff0000"))
cr:rectangle(0, 0, width, height)
cr:fill()
```

### Arcs and Circles

```lua
-- Arc: center (cx, cy), radius r, angle1 to angle2
-- (angles in radians, 0 = right, pi/2 = down, pi = left)
cr:arc(cx, cy, r, 0, 2 * math.pi)  -- full circle
cr:fill()

-- Used in modules/shapes for squircle/rounded shapes:
cr:arc(w - i - ri, ri, ri, -math.pi / 2, 0)  -- top-right corner
cr:arc(w - i - ri, h - i - ri, ri, 0, math.pi / 2)  -- bottom-right
cr:arc(i + ri, h - i - ri, ri, math.pi / 2, math.pi)  -- bottom-left
cr:arc(i + ri, ri, ri, math.pi, 3 * math.pi / 2)  -- top-left
```

### Lines and Curves

```lua
-- Move to starting point (no drawing)
cr:move_to(x, y)

-- Line to (draws a straight line from current position)
cr:line_to(x, y)

-- Relative versions (relative to current position)
cr:rel_move_to(dx, dy)
cr:rel_line_to(dx, dy)

-- Bezier curve
cr:curve_to(cp1x, cp1y, cp2x, cp2y, endx, endy)
cr:rel_curve_to(dx1, dy1, dx2, dy2, dx3, dy3)

-- Close the current path back to the start
cr:close_path()

-- Set line width (in user-space units)
cr:set_line_width(width)
```

### Path Management

```lua
-- Clear the current path
cr:new_path()
```

### Example: Navigator gradient bars (from `modules/layouts/navigator.lua`)

```lua
for i = 1, num do
    local cc = i % 2 == 1 and bg1 or bg2
    local l = i * style.gradstep
    cr:set_source(color(cc))
    cr:move_to(0, (i - 1) * style.gradstep)
    cr:rel_line_to(0, style.gradstep)
    cr:rel_line_to(l, -l)
    cr:rel_line_to(-style.gradstep, 0)
    cr:close_path()
    cr:fill()
end
```

---

## 3. Colors and Sources

### Setting Solid Colors

```lua
-- From hex string via gears.color (preferred — handles many formats)
local gears_color = require("gears.color")
cr:set_source(gears_color("#ff0000"))
cr:set_source(gears_color("#ff0000cc"))  -- with alpha

-- From RGBA directly
cr:set_source_rgba(r, g, b, a)  -- values 0.0-1.0

-- From RGB (alpha defaults to 1.0)
cr:set_source_rgb(r, g, b)
```

### Setting Source from Another Surface

```lua
-- Draw one surface onto another (used in crop_surface, wallpapers)
cr:set_source_surface(source_surf, offset_x, offset_y)
cr:paint()

-- The operator determines how source and destination blend:
cr.operator = cairo.Operator.SOURCE  -- replace destination (default for set_source_surface)
cr.operator = cairo.Operator.OVER    -- alpha-blend source over destination
cr.operator = cairo.Operator.CLEAR   -- clear destination (make transparent)
```

### Icon Recoloring (heavily used in this config)

```lua
local gcolor = require("gears.color")

-- Recolor an SVG/icon to a new color
-- Takes a path or surface, returns a new surface
local colored_icon = gcolor.recolor_image(icon_path, beautiful.fg)
-- or
local colored_icon = gcolor.recolor_image(icon_path, "#ffffff")

-- Used extensively in: button_patterns, applet_button, hover_button,
-- powermenu, titlebar, lock_animation, screenshot_popup
```

### Checking Source Types

```lua
if cairo.Surface:is_type_of(pattern) then
    pattern = cairo.Pattern.create_for_surface(pattern)
end
if not cairo.Pattern:is_type_of(pattern) then
    -- Not a pattern — probably a solid color
end
```

---

## 4. Gradients

### Linear Gradients (used extensively in theme)

```lua
local cairo = require("lgi").cairo

-- Create linear gradient: (x0, y0) to (x1, y1)
local pattern = cairo.Pattern.create_linear(x0, y0, x1, y1)

-- Add color stops (position 0.0 to 1.0)
pattern:add_color_stop_rgba(0, r1, g1, b1, a1)
pattern:add_color_stop_rgba(1, r2, g2, b2, a2)

-- Set as source and paint
cr:set_source(pattern)
cr:paint()
```

Convenience via `gears.color`:

```lua
-- Parse a gradient string (used in theme definitions)
-- Format: "linear:x0,y0:x1,y1:0,#color1:1,#color2"
local pattern = gears_color("linear:0,0:0,32:0,#ff0000:1,#00ff00")

-- Used in theme:
beautiful.bg_gradient_button =
    "linear:0,0:0,32:0," .. beautiful.black .. ":1," .. beautiful.bg_dark
```

### Radial Gradients

```lua
-- Create radial gradient: inner circle (cx0, cy0, r0), outer (cx1, cy1, r1)
local pattern = cairo.Pattern.create_radial(cx0, cy0, r0, cx1, cy1, r1)
pattern:add_color_stop_rgba(0, r, g, b, a)
pattern:add_color_stop_rgba(1, r2, g2, b2, a2)
```

### String-based Gradient Parsing (from `upstream/gears/color.lua`)

```lua
-- The pattern parser in gears.color handles:
-- "linear:x0,y0:x1,y1:0,#color:1,#color:..."
-- "radial:cx0,cy0,r0:cx1,cy1,r1:0,#color:1,#color:..."

-- The theme_assets and background containers use this extensively
```

---

## 5. Surface Manipulation

### Cropping to Aspect Ratio (from `modules/crop_surface/init.lua`)

This is the exact pattern used in this codebase for cropping images:

```lua
local function crop_to_aspect_ratio(ratio, surf)
    local old_w, old_h = gears.surface.get_size(surf)
    local old_ratio = old_w / old_h
    if old_ratio == ratio then return surf end  -- already correct

    -- Calculate crop dimensions
    local new_h, new_w = old_h, old_w
    local offset_h, offset_w = 0, 0
    if old_ratio < ratio then
        new_h = math.ceil(old_w * (1 / ratio))
        offset_h = math.ceil((old_h - new_h) / 2)
    else
        new_w = math.ceil(old_h * ratio)
        offset_w = math.ceil((old_w - new_w) / 2)
    end

    -- Create new surface and copy with offset
    local out_surf = cairo.ImageSurface(cairo.Format.ARGB32, new_w, new_h)
    local cr = cairo.Context(out_surf)
    cr:set_source_surface(surf, -offset_w, -offset_h)
    cr.operator = cairo.Operator.SOURCE
    cr:paint()
    return out_surf
end
```

### Compositing One Surface onto Another

```lua
-- Draw source surface onto destination at position (dx, dy)
local function composite(dest_surf, source_surf, dx, dy)
    local cr = cairo.Context(dest_surf)
    cr:set_source_surface(source_surf, dx, dy)
    cr.operator = cairo.Operator.OVER  -- or SOURCE to replace
    cr:paint()
    return dest_surf
end
```

### Surface Duplication and Transformation

```lua
local surface = require("gears.surface")

-- Duplicate a surface
local dup = surface.duplicate_surface(surf)

-- Scale a surface
local scaled = surface.scale(surf, new_width, new_height)
```

---

## 6. Groups and Operators

### Drawing Groups (used extensively in wibox containers)

Groups allow compositing a set of drawing operations as a single unit:

```lua
-- Start recording drawing operations into a group
cr:push_group()

-- ... drawing operations ...
cr:rectangle(x, y, w, h)
cr:set_source(color("#ff0000"))
cr:fill()

-- Stop recording and use the group as the source
cr:pop_group_to_source()
cr:paint()

-- Or get the group as a pattern for reuse
local pattern = cr:pop_group()
cr:set_source(pattern)
cr:paint()

-- Push group with specific content type
cr:push_group_with_content(cairo.Content.COLOR_ALPHA)
cr:push_group_with_content(cairo.Content.ALPHA)  -- for mask creation
```

### Operators

```lua
-- SOURCE: Replace destination with source (ignores destination alpha)
cr.operator = cairo.Operator.SOURCE

-- OVER: Alpha-blend source over destination (default)
cr.operator = cairo.Operator.OVER

-- CLEAR: Clear destination to transparent
cr.operator = cairo.Operator.CLEAR

-- Used in theme_assets to punch holes in surfaces:
cr:set_operator(cairo.Operator.CLEAR)  -- clear brush
cr:move_to(x, y)
cr:rel_line_to(...)
cr:stroke()
cr:set_operator(cairo.Operator.OVER)   -- restore normal blend
```

### Mask Pattern (from `upstream/wibox/container/background.lua`)

```lua
-- Create an alpha mask from drawing operations:
cr:push_group_with_content(cairo.Content.ALPHA)
-- draw mask shapes
cr:set_source_rgba(0, 0, 0, 1)
cr:rectangle(x, y, w, h)
cr:fill()
cr:set_source_rgba(0, 0, 0, 0)
-- draw transparent holes
local mask = cr:pop_group()

-- Apply the mask when painting:
cr:set_source(source_pattern)
cr:mask(mask)
```

---

## 7. Custom Widget Drawing

### Pattern: make_widget() with fit() and draw()

Used in `modules/layouts/navigator.lua` for custom-painted widgets:

```lua
local wibox = require("wibox")

local function make_custom_widget(args)
    local widg = wibox.widget.base.make_widget()

    -- Store data
    widg._data = { value = args.initial_value or 0 }

    -- Update method
    function widg:set_value(val)
        if widg._data.value ~= val then
            widg._data.value = val
            self:emit_signal("widget::redraw_needed")
        end
    end

    -- Fit: determine natural size (return the space you need)
    function widg:fit(_, width, height)
        return width, height  -- use all available space
    end

    -- Draw: do the actual Cairo painting
    function widg:draw(_, cr, width, height)
        -- cr is a Cairo context, already clipped to the widget area
        -- The coordinate system has (0,0) at the widget's top-left

        -- Draw background
        cr:set_source(color("#ff0000"))
        cr:rectangle(0, 0, width, height)
        cr:fill()

        -- Draw content
        cr:set_source(color("#ffffff"))
        cr:move_to(width / 2, height / 2)
        -- ... custom drawing ...
    end

    return widg
end
```

Key details:
- Always call `self:emit_signal("widget::redraw_needed")` when data changes
- `:fit()` returns the natural dimensions (the widget's preferred size)
- `:draw()` receives a pre-clipped Cairo context — coordinate system starts at (0,0)
- The default `wibox.widget.base.make_widget()` supports all signal and layout machinery

### Shape Functions (from `modules/shapes/init.lua`)

Shape functions are closures that take `(cr, width, height)` and draw a path:

```lua
-- Factory returns a function for use in widget shape properties
local function rrect(radius)
    return function(cr, w, h)
        -- cr: draw a path (do NOT fill or stroke — the caller handles that)
        gears.shape.rounded_rect(cr, w, h, dpi(radius))
    end
end

-- Usage in widget declarations:
local widget = wibox.widget {
    shape = shapes.rrect(10),  -- passes (cr, w, h) automatically
    widget = wibox.container.background,
}
```

Common shape functions from `modules/shapes`:

| Function | Description |
|----------|-------------|
| `rrect(rad)` | Rounded rectangle, all corners radius `rad` |
| `rbar()` | Rounded bar (pill shape) |
| `prrect(tl, tr, br, bl, rad)` | Partially rounded rect — specify which corners |
| `circle(rad)` | Circle/ellipse |
| `squircle(rad, inset)` | Squircle with inset border |

---

## 8. Theme Asset Generation (from `upstream/beautiful/theme_assets.lua`)

### Taglist Squares (solid fill / outline)

```lua
-- Selected: solid filled square
function theme_assets.taglist_squares_sel(size, fg)
    local img = cairo.ImageSurface(cairo.Format.ARGB32, size, size)
    local cr = cairo.Context(img)
    cr:set_source(gears_color(fg))
    cr:paint()
    return img
end

-- Unselected: outlined square
function theme_assets.taglist_squares_unsel(size, fg)
    local img = cairo.ImageSurface(cairo.Format.ARGB32, size, size)
    local cr = cairo.Context(img)
    cr:set_source(gears_color(fg))
    cr:set_line_width(size / 4)
    cr:rectangle(0, 0, size, size)
    cr:stroke()
    return img
end
```

### Generating Named Assets with Recoloring (from theme_assets)

```lua
-- Generate multiple layouts/icons at once using recolor_image
for _, layout_data in ipairs(layouts) do
    local name = layout_data[1]
    local image = layout_data[2]
    theme[name] = recolor_image(image, color)
end
```

### Putting Text on a Surface (theme_assets gen_awesome_name)

```lua
-- Uses PangoCairo for text layout on a Cairo surface
local PangoCairo = lgi.PangoCairo
local ctx = PangoCairo.font_map_get_default():create_context()
-- cr is the Cairo context for the surface
-- Use PangoCairo for text rendering (Pango handles font fallback, layout, etc.)
```

---

## 9. Drawing Pipeline (for debugging)

When debugging display issues, understand that the widget draw pipeline is:

```
wibox/drawable.lua:  main loop → computes dirty region
  └─ drawable:draw() → creates cairo.Context → paints background + wallpaper
      └─ wibox/hierarchy.lua:draw() → per-widget
          ├─ cr:save() → cr:transform(matrix) → cr:clip()
          ├─ cr:push_group()
          │   └─ widget:draw(cr, width, height)  ← YOUR CUSTOM DRAW CODE
          ├─ cr:pop_group_to_source()
          └─ cr:paint_with_alpha(opacity)
          └─ cr:restore()
```

For container backgrounds (the most common drawing in this config):

```
wibox/container/background.lua:draw()
  ├─ cr:save()
  ├─ Apply shape clipping (if shape is set)
  ├─ Draw background gradient/color/image
  ├─ Draw foreground
  ├─ cr:restore()
  └─ Draw children (the widget content)
```

---

## 10. Common Patterns in this Config

### Gradient Button Backgrounds

```lua
-- Theme defines gradient strings:
beautiful.bg_gradient_button = "linear:0,0:0,32:0,#1a1a2e:1,#16213e"
beautiful.bg_gradient_button_alt = "linear:0,0:0,32:0,#16213e:1,#0f3460"
beautiful.bg_gradient_recessed = "linear:0,0:0,32:0,#0f3460:1,#1a1a2e"

-- Applied automatically via widget bg property:
bg = beautiful.bg_gradient_button
-- wibox.container.background parses the gradient string automatically
```

### Icon Recoloring Pipeline

```lua
-- 1. Load SVG path
-- 2. Recolor with current theme color
-- 3. Set as image source
local image = gears.color.recolor_image(icon_svg_path, beautiful.fg)
widget:set_image(image)
```

### Surface Cropping for Circular/Avatar Images

```lua
-- 1. Load the source image surface
local img = gears.surface.load_silently(path)
-- 2. Crop to 1:1 aspect ratio
local cropped = crop_to_aspect_ratio(1, img)
-- 3. Use as a widget with circular shape
wibox.widget {
    image = cropped,
    shape = shapes.circle(),
    widget = wibox.container.background,
}
```

### Widget-to-Cairo Example: Progress Bars, Arc Charts

The upstream widgets (`wibox.widget.progressbar`, `wibox.container.arcchart`) use
`:draw()` methods with Cairo. For custom progress visualization, study these:

```lua
-- In a custom :draw():
function widg:draw(_, cr, width, height)
    -- Background
    cr:set_source(color(bg))
    cr:rectangle(0, 0, width, height)
    cr:fill()

    -- Progress fill (clipped to shape)
    cr:rectangle(0, 0, width * self._data.value, height)
    cr:set_source(color(fg))
    cr:fill()
end
```

### Image with Background Layer

```lua
-- Composite an icon over a background shape:
local img = cairo.ImageSurface(cairo.Format.ARGB32, size, size)
local cr = cairo.Context(img)

-- Background circle
cr:set_source(gears_color(bg_color))
cr:arc(center, center, radius, 0, 2 * math.pi)
cr:fill()

-- Icon on top
cr:set_source_surface(icon_surface, offset, offset)
cr.operator = cairo.Operator.OVER
cr:paint()

return img
```

---

## Red Flags

- **Do NOT** call `cr:finish()` or `cr:destroy()` — Lua's GC handles surface cleanup
- **Do NOT** assume surface dimensions without calling `gears.surface.get_size()`
- **Do NOT** use `os.execute()` for image processing — use Cairo
- **Do NOT** hardcode pixel values — always use `dpi()` for theme-aware sizing
- **Do NOT** use `cairo.Context.create(surface)` — use `cairo.Context(surface)` instead
- **ALWAYS** use `gears.color()` to parse color strings rather than manual hex parsing
- **ALWAYS** call `cr:save()` before modifying transforms/clip and `cr:restore()` after
- When drawing in a widget `:draw()` method, the context is already clipped — do NOT call `cr:clip()` unless absolutely necessary
- `cr.operator` is set as an assignment (`cr.operator = cairo.Operator.OVER`), NOT a method call
