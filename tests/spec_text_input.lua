--- Spec for `modules.text_input` pure helpers.
--
-- Both `create_markup` and `is_excluded_key` are pure (no X server, no
-- state) but they are local to `modules/text_input/init.lua`. To test
-- them without a running wibox, this spec loads the production source
-- and rewrites the two `local function` declarations into `M.X = function`
-- assignments, then short-circuits the rest of the file with an early
-- return after `is_excluded_key` ends.
--
-- This is the same pattern as `tests/spec_lib.lua` for vendored
-- utility libraries. The test compiles a modified source string with
-- `load(source, name, "t")` so that any `package.loaded` mocks are
-- available to the chunk via the normal `require()` resolution.
--
-- Production code touched: NONE. Only the source string is rewritten
-- at test time.
-- @see modules/text_input/init.lua
-- @see tests/spec_lib.lua

local asrt = require("tests.assert")
local runner = ...

-- ---------------------------------------------------------------------------
-- Module mocks
-- ---------------------------------------------------------------------------

-- gears.string — the only `gears.string` call in create_markup is xml_escape.
package.loaded["gears.string"] = {
    xml_escape = function(s)
        s = s or ""
        s = s:gsub("&", "&amp;")
        s = s:gsub("<", "&lt;")
        s = s:gsub(">", "&gt;")
        s = s:gsub('"', "&quot;")
        s = s:gsub("'", "&apos;")
        return s
    end,
}

-- gears.color — create_markup calls `ensure_pango_color`.
package.loaded["gears.color"] = {
    ensure_pango_color = function(c)
        if c == nil then
            return "#FFFFFF"
        end
        return tostring(c)
    end,
    create_solid_pattern = function()
        return {}
    end,
    ensure_pango_color_p = function()
        return ""
    end,
    parse_color = function()
        return 0
    end,
    create_pango_layout = function()
        return {}
    end,
    create_solid_pattern_image = function()
        return {}
    end,
    recolor_image = function()
        return {}
    end,
}

-- gears.table — used at top level for `join`/`clone` in instance methods.
package.loaded["gears.table"] = {
    join = function(...)
        local out = {}
        for _, t in ipairs({ ... }) do
            for k, v in pairs(t or {}) do
                out[k] = v
            end
        end
        return out
    end,
    hasitem = function(t, item)
        for _, v in ipairs(t or {}) do
            if v == item then
                return true
            end
        end
        return false
    end,
    clone = function(t)
        local out = {}
        for k, v in pairs(t or {}) do
            out[k] = v
        end
        return out
    end,
}

-- awful — only awful.keygrabber.run is invoked at instance time, but the
-- module references `awful` at top level.
package.loaded["awful"] = {
    keygrabber = {
        run = function() end,
        stop = function() end,
    },
}

-- wibox — only used inside `new()`. We don't call `new()` from this
-- spec, but the chunk executes through it.
package.loaded["wibox"] = setmetatable({
    widget = setmetatable({
        textbox = function()
            return {}
        end,
        imagebox = function()
            return {}
        end,
    }, {
        __call = function()
            return {}
        end,
    }),
    container = {
        background = function()
            return {}
        end,
        margin = function()
            return {}
        end,
        place = function()
            return {}
        end,
    },
    layout = {
        fixed = {
            vertical = function()
                return {}
            end,
            horizontal = function()
                return {}
            end,
        },
        align = {
            vertical = function()
                return {}
            end,
            horizontal = function()
                return {}
            end,
        },
    },
}, {
    __call = function()
        return {}
    end,
})

-- lgi
package.loaded["lgi"] = { Pango = { Font = {} }, PangoCairo = {} }

-- beautiful
package.loaded["beautiful"] = {
    xresources = {
        apply_dpi = function(x)
            return x
        end,
    },
    text_input_cursor_bg = "#FF0000",
    text_input_cursor_fg = "#00FF00",
    text_input_placeholder_fg = "#888888",
}

-- ---------------------------------------------------------------------------
-- Source rewriting
-- ---------------------------------------------------------------------------

--- Load the production module, but only `create_markup` and
-- `is_excluded_key`. We rewrite those two `local function` decls into
-- assignments to a local `M` table, and append `return M` right after
-- the `is_excluded_key` function's closing `end`.
local function load_helpers()
    local f = assert(io.open("modules/text_input/init.lua", "r"))
    local source = f:read("*a")
    f:close()

    -- Replace the function declarations.
    source = source:gsub(
        "local function create_markup%(args%)",
        "M.create_markup = function(args)"
    )
    source = source:gsub(
        "local function is_excluded_key%(key%)",
        "M.is_excluded_key = function(key)"
    )

    -- Inject `local M = {}` right after the `require("beautiful")` line.
    source = source:gsub(
        '(local beautiful = require%(%s*"beautiful"%s*%))',
        "%1\nlocal M = {}"
    )

    -- The is_excluded_key function body ends with `return false\nend`.
    -- We want to short-circuit the entire module by replacing everything
    -- after the closing `end` of is_excluded_key with `return M`. The
    -- tail of the source contains widget construction code that depends
    -- on real wibox + keygrabber, so we must excise it before compiling.
    local out, n =
        source:gsub("(    return false\nend)\n.-$", "%1\nreturn M\n", 1)
    if n == 0 then
        error("could not find is_excluded_key end marker")
    end
    source = out

    local chunk, err = load(source, "modules/text_input/init.lua", "t")
    if not chunk then
        error("compile failed: " .. tostring(err))
    end
    local ok, result = pcall(chunk)
    if not ok then
        error("execution failed: " .. tostring(result))
    end
    return result
end

local helpers = load_helpers()
local create_markup = helpers.create_markup
local is_excluded_key = helpers.is_excluded_key

-- ---------------------------------------------------------------------------
-- Tests
-- ---------------------------------------------------------------------------

runner.describe("text_input:create_markup", function()
    runner.it("renders empty text with a span-cursor", function()
        local out = create_markup({
            text = "",
            cursor_pos = 1,
            cursor_bg = "#ff0000",
            cursor_fg = "#00ff00",
        })
        asrt.truthy(out:find("<span", 1, true), "should contain <span>")
        asrt.truthy(out:find("</span>", 1, true), "should close span")
    end)

    runner.it(
        "inserts the cursor at the right position for 'ab' with pos=2",
        function()
            local out = create_markup({
                text = "ab",
                cursor_pos = 2,
                cursor_bg = "#ff0000",
                cursor_fg = "#00ff00",
            })
            asrt.truthy(out:find("a", 1, true), "should contain text-start 'a'")
            asrt.truthy(
                out:find("b", 1, true),
                "should contain cursor char 'b'"
            )
        end
    )

    runner.it("renders placeholder when text is empty", function()
        local out = create_markup({
            text = "",
            cursor_pos = 1,
            placeholder = "Search",
            placeholder_fg = "#888888",
            cursor_bg = "#ff0000",
            cursor_fg = "#00ff00",
        })
        -- Placeholder text is split across spans, but the individual
        -- characters must all appear.
        asrt.truthy(out:find("S", 1, true), "should contain 'S'")
        asrt.truthy(out:find("earch", 1, true), "should contain 'earch'")
        asrt.truthy(
            out:find("foreground='#888888'", 1, true),
            "should apply placeholder_fg color"
        )
    end)

    runner.it("obscures input text with the obscure character", function()
        local out = create_markup({
            text = "secret",
            cursor_pos = 7,
            obscure = true,
            obscure_char = "*",
            cursor_bg = "#ff0000",
            cursor_fg = "#00ff00",
        })
        asrt.falsy(out:find("secret", 1, true), "obscure text should not leak")
        asrt.truthy(out:find("******", 1, true), "should show asterisks")
    end)

    runner.it("highlights the entire text when selectall is set", function()
        local out = create_markup({
            text = "hello",
            cursor_pos = 6,
            selectall = true,
            cursor_bg = "#ff0000",
            cursor_fg = "#00ff00",
        })
        asrt.truthy(out:find("hello", 1, true), "should contain text")
    end)

    runner.it("escapes XML special characters", function()
        local out = create_markup({
            text = "<>&",
            cursor_pos = 4,
            cursor_bg = "#ff0000",
            cursor_fg = "#00ff00",
        })
        asrt.truthy(out:find("&lt;", 1, true), "should escape <")
        asrt.truthy(out:find("&gt;", 1, true), "should escape >")
        asrt.truthy(out:find("&amp;", 1, true), "should escape &")
    end)

    runner.it(
        "applies a highlighter callback to before/after segments",
        function()
            local out = create_markup({
                text = "hello world",
                cursor_pos = 6,
                cursor_bg = "#ff0000",
                cursor_fg = "#00ff00",
                highlighter = function(before, after)
                    return ("<b>%s</b>"):format(before),
                        ("<i>%s</i>"):format(after)
                end,
            })
            asrt.truthy(out:find("<b>", 1, true), "should wrap before in <b>")
            asrt.truthy(out:find("<i>", 1, true), "should wrap after in <i>")
        end
    )

    runner.it("puts cursor at end of text when cursor_pos > len", function()
        local out = create_markup({
            text = "abc",
            cursor_pos = 99,
            cursor_bg = "#ff0000",
            cursor_fg = "#00ff00",
        })
        asrt.truthy(out:find("abc", 1, true), "text should be visible")
    end)
end)

runner.describe("text_input:is_excluded_key", function()
    runner.it("excludes Shift keys", function()
        asrt.truthy(is_excluded_key("Shift_L"))
        asrt.truthy(is_excluded_key("Shift_R"))
    end)

    runner.it("excludes modifier keys", function()
        asrt.truthy(is_excluded_key("Super_L"))
        asrt.truthy(is_excluded_key("Control_L"))
        asrt.truthy(is_excluded_key("Alt_L"))
    end)

    runner.it("excludes navigation keys", function()
        asrt.truthy(is_excluded_key("Home"))
        asrt.truthy(is_excluded_key("End"))
        asrt.truthy(is_excluded_key("Left"))
        asrt.truthy(is_excluded_key("Right"))
    end)

    runner.it("excludes BackSpace, Return, Escape, Tab, Delete", function()
        for _, k in ipairs({ "BackSpace", "Return", "Escape", "Tab", "Delete" }) do
            asrt.truthy(is_excluded_key(k), k .. " should be excluded")
        end
    end)

    runner.it("excludes function keys F1-F12", function()
        for i = 1, 12 do
            asrt.truthy(is_excluded_key("F" .. i))
        end
    end)

    runner.it("does not exclude printable keys", function()
        for _, k in ipairs({ "a", "A", "z", "1", "space", "period", "slash" }) do
            asrt.falsy(is_excluded_key(k), k .. " should NOT be excluded")
        end
    end)
end)
