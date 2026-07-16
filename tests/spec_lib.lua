--- Spec for `lib` utility helpers in `lib/init.lua`.
-- Mirrors the production code so we can unit-test without loading the
-- awesome runtime. `lib.inspect` and `lib.json` are simple passthroughs
-- and not deeply tested here — they're exercised by the screenshot and
-- notification cache code in practice.

local assert = require("tests.assert")
local runner = ...

-- Mirror of the production helpers.
local function create_markup(text, args)
    args = args or {}
    local font = args.font and "font='" .. args.font .. "' " or ""
    local size = args.size and "size='" .. args.size .. "' " or ""
    local style = args.style and "style='" .. args.style .. "' " or ""
    local weight = args.weight and "weight='" .. args.weight .. "' " or ""
    local stretch = args.stretch and "stretch='" .. args.stretch .. "' " or ""
    local font_scale = args.font_scale
            and "font_scale='" .. args.font_scale .. "' "
        or ""
    local underline = args.underline and "underline='" .. args.underline .. "' "
        or ""
    local overline = args.overline and "overline='" .. args.overline .. "' "
        or ""
    local local_strike = args.strikethrough
            and "strikethrough='" .. args.strikethrough .. "' "
        or ""
    local alpha = args.alpha and "alpha='" .. args.alpha .. "' " or ""
    local fg = args.fg and "foreground='" .. args.fg .. "' " or ""
    local bg = args.bg and "background='" .. args.bg .. "'" or ""
    return "<span "
        .. font
        .. size
        .. style
        .. weight
        .. stretch
        .. font_scale
        .. underline
        .. overline
        .. local_strike
        .. alpha
        .. fg
        .. bg
        .. ">"
        .. text
        .. "</span>"
end

local function lua_escape(str)
    return str:gsub("[%[%]%(%)%.%-%+%?%*%^%$%%]", "%%%1")
end

local function has_common(t1, t2)
    local common = {}
    for _, v1 in pairs(t1) do
        for _, v2 in pairs(t2) do
            if v1 == v2 then
                table.insert(common, v1)
            end
        end
    end
    return #common > 0 and common or nil
end

local function remove_nonindex(tbl, val)
    for i, v in ipairs(tbl) do
        if v == val then
            table.remove(tbl, i)
        end
    end
end

local function file_exists(file)
    local f = io.open(file, "r")
    if f ~= nil then
        io.close(f)
        return true
    end
    return false
end

local function is_supported(file, formats)
    local supported = false
    for _, format in ipairs(formats) do
        if file:match("/.+%." .. format .. "$") then
            supported = true
            break
        end
    end
    return supported
end

-- Use the real inspect library (pure Lua) for table_to_file tests.
local inspect = require("lib.inspect")
-- Mirror of `lib.table_to_file` — writes a Lua table as a returnable string
-- using `inspect` with tab-indent, then reads it back to verify.
local function table_to_file(tbl, file)
    if not file or not tbl then
        return
    end
    local success, inspected = pcall(inspect, tbl, { indent = "\t" })
    if not success then
        return
    end
    local wfile = io.open(file, "w")
    if not wfile then
        return
    end
    wfile:write("return " .. inspected)
    wfile:close()
end

runner.describe("lib.create_markup", function()
    runner.it("wraps text in <span></span> with no attributes", function()
        assert.eq(create_markup("hello", {}), "<span >hello</span>")
    end)

    runner.it("emits font attribute when set", function()
        assert.eq(
            create_markup("x", { font = "Mono" }),
            "<span font='Mono' >x</span>"
        )
    end)

    runner.it("emits foreground and background", function()
        local out = create_markup("x", { fg = "#ff0000", bg = "#000000" })
        assert.truthy(out:find("foreground='#ff0000'"))
        assert.truthy(out:find("background='#000000'"))
    end)

    runner.it("emits all attributes when all are set", function()
        local out = create_markup("x", {
            font = "F",
            size = "10",
            style = "italic",
            weight = "bold",
            stretch = "expanded",
            font_scale = "1.0",
            underline = "single",
            overline = "single",
            strikethrough = "true",
            alpha = "50%",
            fg = "#fff",
            bg = "#000",
        })
        assert.truthy(out:find("font='F'"))
        assert.truthy(out:find("size='10'"))
        assert.truthy(out:find("style='italic'"))
        assert.truthy(out:find("weight='bold'"))
        assert.truthy(out:find("underline='single'"))
        -- "50%" contains "%" which is a Lua pattern special char, so use
        -- plain find (4th arg = true) to avoid pattern matching.
        assert.truthy(out:find("alpha='50%'", 1, true))
    end)

    runner.it("treats nil args as no attributes", function()
        assert.eq(create_markup("x", nil), "<span >x</span>")
    end)
end)

runner.describe("lib.lua_escape", function()
    runner.it("escapes square brackets", function()
        assert.eq(lua_escape("a[b]"), "a%[b%]")
    end)

    runner.it("escapes parens", function()
        assert.eq(lua_escape("(a)"), "%(a%)")
    end)

    runner.it("escapes quantifiers", function()
        assert.eq(lua_escape("a.b+c?d*e"), "a%.b%+c%?d%*e")
    end)

    runner.it("escapes anchors", function()
        assert.eq(lua_escape("^$"), "%^%$")
    end)

    runner.it("escapes the percent sign", function()
        assert.eq(lua_escape("50%"), "50%%")
    end)

    runner.it("escaped string works as a literal pattern", function()
        local pat = lua_escape("foo[bar]")
        assert.truthy(("foo[bar]"):find(pat))
        assert.falsy(("fooXYZbar"):find(pat))
    end)
end)

runner.describe("lib.has_common", function()
    runner.it("returns the shared values when tables overlap", function()
        local r = has_common({ 1, 2, 3 }, { 3, 4, 5 })
        assert.eq(#r, 1)
        assert.eq(r[1], 3)
    end)

    runner.it("returns nil when no overlap", function()
        assert.eq(has_common({ 1, 2 }, { 3, 4 }), nil)
    end)

    runner.it("handles multiple overlaps", function()
        local r = has_common({ 1, 2, 3 }, { 2, 3, 4 })
        assert.eq(#r, 2)
    end)

    runner.it("works with string values", function()
        local r = has_common({ "a", "b" }, { "b", "c" })
        assert.eq(#r, 1)
        assert.eq(r[1], "b")
    end)
end)

runner.describe("lib.remove_nonindex", function()
    runner.it(
        "removes the first matching occurrence (then continues)",
        function()
            -- {1,2,3,2,5} → first 2 at i=2 is removed → {1,3,2,5}.
            -- Next i=3 hits the other 2, removed → {1,3,5}.
            -- i=4 is then out of range (table is now length 3).
            local t = { 1, 2, 3, 2, 5 }
            remove_nonindex(t, 2)
            assert.eq(#t, 3)
            assert.eq(t[1], 1)
            assert.eq(t[2], 3)
            assert.eq(t[3], 5)
        end
    )

    runner.it("with duplicates, removes the first 2 occurrences", function()
        local t = { 7, 7, 7, 8 }
        remove_nonindex(t, 7)
        assert.eq(#t, 2)
        assert.eq(t[1], 7)
        assert.eq(t[2], 8)
    end)

    runner.it("no-op when value not present", function()
        local t = { 1, 2, 3 }
        remove_nonindex(t, 99)
        assert.eq(#t, 3)
    end)
end)

runner.describe("lib.file_exists", function()
    runner.it("returns true for existing files", function()
        local f = os.tmpname()
        local h = io.open(f, "w")
        h:write("hi")
        h:close()
        assert.eq(file_exists(f), true)
        os.remove(f)
    end)

    runner.it("returns false for nonexistent paths", function()
        assert.eq(file_exists("/nonexistent/path/abc/xyz"), false)
    end)
end)

runner.describe("lib.is_supported", function()
    runner.it("matches by extension", function()
        assert.eq(is_supported("/foo/bar.png", { "png", "jpg" }), true)
    end)

    runner.it("rejects when extension is not in the list", function()
        assert.eq(is_supported("/foo/bar.bmp", { "png", "jpg" }), false)
    end)

    runner.it("anchors the match to end of path", function()
        -- "foopng" should NOT match ".png" because the regex is "/.+\\.png$"
        assert.eq(is_supported("/foopng", { "png" }), false)
    end)

    runner.it("requires a slash in the path (matches the regex)", function()
        -- A bare filename like "bar.png" does not contain "/" so the
        -- pattern won't match. Document this behavior.
        assert.eq(is_supported("bar.png", { "png" }), false)
    end)
end)

runner.describe("lib.table_to_file", function()
    runner.it("writes a flat table and reads it back", function()
        local f = os.tmpname()
        table_to_file({ a = 1, b = 2 }, f)
        local ok, result = pcall(dofile, f)
        assert.eq(ok, true)
        assert.eq(result.a, 1)
        assert.eq(result.b, 2)
        os.remove(f)
    end)

    runner.it("writes a nested table and reads it back", function()
        local f = os.tmpname()
        table_to_file({ outer = { inner = 42 } }, f)
        local ok, result = pcall(dofile, f)
        assert.eq(ok, true)
        assert.eq(result.outer.inner, 42)
        os.remove(f)
    end)

    runner.it("returns nil when file or tbl is nil", function()
        local f = os.tmpname()
        assert.eq(table_to_file(nil, f), nil)
        assert.eq(table_to_file({}, nil), nil)
        os.remove(f)
    end)
end)
