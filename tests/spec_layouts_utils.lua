--- Spec for `modules.layouts.widgets.utils` pure helpers.
-- Mirrors the production code so we can unit-test without running Xephyr.
-- The cairo helpers (`cairo_set_font`, `cairo_textcentre`) take a cairo
-- context object — we use a fake `cr` table that records method calls so
-- we can assert what would have been drawn.

local assert = require("tests.assert")
local runner = ...

-- Mirror of the production code.
local ignored_mod = { "Unknown", "Mod2" }

local function match_grabber(rawkey, mod, _key)
    for i, m in ipairs(mod) do
        if _G.gtable_hasitem(ignored_mod, m) then
            table.remove(mod, i)
            break
        end
    end
    local modcheck = #mod == #rawkey[1]
    for _, v in ipairs(mod) do
        modcheck = modcheck and _G.gtable_hasitem(rawkey[1], v)
    end
    return modcheck and _key:lower() == rawkey[2]:lower()
end

-- We need a minimal gtable.hasitem for the test; monkey-patch a global
-- helper that the mirror above reads from.
_G.gtable_hasitem = function(t, item)
    for _, v in pairs(t) do
        if v == item then
            return true
        end
    end
    return false
end

local function table_merge(t1, t2)
    -- shallow deep-clone for nested tables
    local function clone(t)
        local out = {}
        for k, v in pairs(t) do
            out[k] = type(v) == "table" and clone(v) or v
        end
        return out
    end
    local ret = clone(t1)
    for k, v in pairs(t2) do
        if type(v) == "table" and ret[k] and type(ret[k]) == "table" then
            ret[k] = table_merge(ret[k], v)
        else
            ret[k] = v
        end
    end
    return ret
end

local function table_check(t, s)
    local v = t
    for key in string.gmatch(s, "([^%.]+)(%.?)") do
        if v[key] then
            v = v[key]
        else
            return nil
        end
    end
    return v
end

runner.describe("utils.match_grabber", function()
    runner.it("matches a single-modifier binding", function()
        assert.truthy(match_grabber({ { "Mod4" }, "F2" }, { "Mod4" }, "F2"))
    end)

    runner.it("is case-insensitive on the key", function()
        assert.truthy(match_grabber({ { "Mod4" }, "F2" }, { "Mod4" }, "f2"))
    end)

    runner.it("rejects when modifiers don't match", function()
        assert.falsy(match_grabber({ { "Mod4" }, "F2" }, { "Control" }, "F2"))
    end)

    runner.it("rejects when key doesn't match", function()
        assert.falsy(match_grabber({ { "Mod4" }, "F2" }, { "Mod4" }, "F3"))
    end)

    runner.it(
        "strips 'Unknown' and 'Mod2' noise modifiers from the event",
        function()
            local event_mods = { "Unknown", "Mod4" }
            assert.truthy(match_grabber({ { "Mod4" }, "F2" }, event_mods, "F2"))
            -- After the call, the 'Unknown' noise modifier should be removed
            assert.eq(#event_mods, 1)
            assert.eq(event_mods[1], "Mod4")
        end
    )

    runner.it("matches multi-modifier bindings", function()
        assert.truthy(
            match_grabber(
                { { "Mod4", "Control" }, "s" },
                { "Mod4", "Control" },
                "s"
            )
        )
    end)

    runner.it("rejects when event has extra modifiers", function()
        assert.falsy(
            match_grabber({ { "Mod4" }, "F2" }, { "Mod4", "Shift" }, "F2")
        )
    end)
end)

runner.describe("utils.table_merge", function()
    runner.it("merges flat tables, t2 wins on scalar conflicts", function()
        local merged = table_merge({ a = 1, b = 2 }, { b = 99, c = 3 })
        assert.eq(merged.a, 1)
        assert.eq(merged.b, 99)
        assert.eq(merged.c, 3)
    end)

    runner.it("does not mutate t1", function()
        local t1 = { a = 1, nested = { x = 10 } }
        table_merge(t1, { nested = { x = 99 } })
        assert.eq(t1.nested.x, 10)
    end)

    runner.it("deep-merges nested tables", function()
        local merged = table_merge(
            { a = { x = 1, y = 2 } },
            { a = { y = 99, z = 3 } }
        )
        assert.eq(merged.a.x, 1)
        assert.eq(merged.a.y, 99)
        assert.eq(merged.a.z, 3)
    end)

    runner.it("handles empty inputs", function()
        local merged = table_merge({}, { a = 1 })
        assert.eq(merged.a, 1)
    end)
end)

runner.describe("utils.table_check", function()
    runner.it("returns top-level value for single key", function()
        local t = { foo = 42 }
        assert.eq(table_check(t, "foo"), 42)
    end)

    runner.it("walks a dotted path", function()
        local t = { service = { navigator = { active = true } } }
        assert.eq(table_check(t, "service.navigator.active"), true)
    end)

    runner.it("returns nil for missing path", function()
        local t = { service = { navigator = {} } }
        assert.eq(table_check(t, "service.missing.key"), nil)
    end)

    runner.it("returns nil for nil middle of path", function()
        local t = { service = nil }
        assert.eq(table_check(t, "service.foo"), nil)
    end)

    runner.it("handles empty path", function()
        local t = { foo = 1 }
        assert.eq(table_check(t, ""), t)
    end)
end)

runner.describe("utils.cairo_set_font", function()
    runner.it("calls select_font_face with defaults", function()
        local calls = {}
        local cr = {
            select_font_face = function(self, font, slant, face)
                table.insert(calls, { "select_font_face", font, slant, face })
            end,
            set_font_size = function(self, size)
                table.insert(calls, { "set_font_size", size })
            end,
        }
        -- Mirror the production helper
        local function cairo_set_font(cr, style)
            cr:select_font_face(
                style.font or "Sans",
                style.slant or 0,
                style.face or 1
            )
            cr:set_font_size(style.size or 22)
        end
        cairo_set_font(cr, {})
        assert.eq(#calls, 2)
        assert.eq(calls[1][1], "select_font_face")
        assert.eq(calls[1][2], "Sans")
        assert.eq(calls[1][3], 0)
        assert.eq(calls[1][4], 1)
        assert.eq(calls[2][1], "set_font_size")
        assert.eq(calls[2][2], 22)
    end)

    runner.it("respects explicit style overrides", function()
        local calls = {}
        local cr = {
            select_font_face = function(self, font, slant, face)
                table.insert(calls, { font, slant, face })
            end,
            set_font_size = function(self, size)
                table.insert(calls, { size })
            end,
        }
        local function cairo_set_font(cr, style)
            cr:select_font_face(
                style.font or "Sans",
                style.slant or 0,
                style.face or 1
            )
            cr:set_font_size(style.size or 22)
        end
        cairo_set_font(cr, { font = "Mono", slant = 1, face = 2, size = 32 })
        assert.eq(calls[1][1], "Mono")
        assert.eq(calls[1][2], 1)
        assert.eq(calls[1][3], 2)
        assert.eq(calls[2][1], 32)
    end)
end)
