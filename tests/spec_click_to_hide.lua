--- Spec for `modules.click_to_hide` popup state machine.
-- The module is a singleton that tracks which popup is "active" and
-- coordinates mutual-exclusion behavior between popups. We mock
-- `awful.keygrabber` so we can drive the state machine without a real
-- X server, and we use a fake `wibox` factory to construct widget-like
-- objects with `connect_signal` / `set_name` / `visible`.

local assert = require("tests.assert")
local runner = ...

-- ------------------------------------------------------------------
-- Mocks
-- ------------------------------------------------------------------

-- Track which signals were connected to which widgets, in registration
-- order. This lets us drive the production logic in a controlled way.
local signal_handlers = {}

local keygrabber_active = false
local function set_keygrabber_active(v)
    keygrabber_active = v
end
local function get_keygrabber_active()
    return keygrabber_active
end

local last_keygrabber_callback = nil
package.loaded["awful"] = {
    keygrabber = {
        run = function(cb)
            last_keygrabber_callback = cb
            set_keygrabber_active(true)
            return "fake-grabber-handle"
        end,
        stop = function(handle)
            set_keygrabber_active(false)
        end,
    },
}

package.loaded["beautiful"] = {}

-- Build a fake popup widget that records its `visible` and `name` changes.
local function make_widget(name)
    local w = {
        name = name,
        visible = false,
    }
    function w:connect_signal(signal, handler)
        signal_handlers[signal] = signal_handlers[signal] or {}
        table.insert(signal_handlers[signal], { w = w, handler = handler })
    end
    function w:emit(signal, ...)
        if signal_handlers[signal] then
            for _, entry in ipairs(signal_handlers[signal]) do
                if entry.w == w then
                    entry.handler(w, ...)
                end
            end
        end
    end
    function w:set_name(n)
        w.name = n
    end
    return w
end

-- Reset state for each test
local function reset_state()
    signal_handlers = {}
    set_keygrabber_active(false)
    last_keygrabber_callback = nil
    -- Force re-load of the module so the singleton state is fresh
    package.loaded["modules.click_to_hide"] = nil
end

-- ------------------------------------------------------------------
-- Tests
-- ------------------------------------------------------------------

runner.describe("click_to_hide:popup registration", function()
    runner.it("registers a popup and assigns default name", function()
        reset_state()
        local click_to_hide = require("modules.click_to_hide")
        local w = make_widget("test")
        click_to_hide.popup(w, function() end)
        assert.eq(w.name, "awesome-popup")
    end)

    runner.it("respects custom popup_name option", function()
        reset_state()
        local click_to_hide = require("modules.click_to_hide")
        local w = make_widget("test")
        click_to_hide.popup(w, function() end, { popup_name = "my-popup" })
        assert.eq(w.name, "my-popup")
    end)

    runner.it("connects to property::visible and widget::destroyed", function()
        reset_state()
        local click_to_hide = require("modules.click_to_hide")
        local w = make_widget("test")
        click_to_hide.popup(w, function() end)
        assert.truthy(signal_handlers["property::visible"])
        assert.truthy(signal_handlers["widget::destroyed"])
    end)

    runner.it("exclusive defaults to true", function()
        reset_state()
        local click_to_hide = require("modules.click_to_hide")
        local w1 = make_widget("a")
        local w2 = make_widget("b")
        local w1_hidden, w2_hidden = false, false
        click_to_hide.popup(w1, function() w1_hidden = true end)
        click_to_hide.popup(w2, function() w2_hidden = true end, { exclusive = true })
        -- First, make w1 visible (this activates it)
        w1.visible = true
        w1:emit("property::visible", w1)
        assert.falsy(w1_hidden)
        -- Then make w2 visible — w1 should now be hidden (mutual exclusion)
        w2.visible = true
        w2:emit("property::visible", w2)
        assert.truthy(w1_hidden)
        assert.falsy(w2_hidden)
    end)

    runner.it("exclusive=false does not hide other popups", function()
        reset_state()
        local click_to_hide = require("modules.click_to_hide")
        local w1 = make_widget("a")
        local w2 = make_widget("b")
        local w1_hidden = false
        click_to_hide.popup(w1, function() w1_hidden = true end)
        click_to_hide.popup(w2, function() end, { exclusive = false })
        w2.visible = true
        w2:emit("property::visible", w2)
        assert.falsy(w1_hidden)
    end)
end)

runner.describe("click_to_hide:state transitions", function()
    runner.it("hide is a no-op when widget is not visible", function()
        reset_state()
        local click_to_hide = require("modules.click_to_hide")
        local w = make_widget("test")
        local hidden = false
        click_to_hide.popup(w, function() hidden = true end)
        -- Force w.visible = false and emit (production should skip)
        w:emit("property::visible", w)
        assert.falsy(hidden)
    end)

    runner.it("does NOT emit hide callback when widget hides itself", function()
        -- The hide_function is only called when ANOTHER popup activates
        -- and requests mutual exclusion. A popup hiding itself just
        -- deactivates the active-popup state, no callback fires.
        reset_state()
        local click_to_hide = require("modules.click_to_hide")
        local w = make_widget("test")
        local hidden = false
        click_to_hide.popup(w, function() hidden = true end)
        w.visible = true
        w:emit("property::visible", w)
        assert.falsy(hidden)
        w.visible = false
        w:emit("property::visible", w)
        assert.falsy(hidden) -- still false; self-hide does not call callback
    end)

    runner.it("starts escape keygrabber when popup is shown with enable_escape=true", function()
        reset_state()
        local click_to_hide = require("modules.click_to_hide")
        local w = make_widget("test")
        click_to_hide.popup(w, function() end) -- enable_escape defaults to true
        w.visible = true
        w:emit("property::visible", w)
        assert.truthy(get_keygrabber_active())
    end)

    runner.it("does NOT start escape keygrabber when enable_escape=false", function()
        reset_state()
        local click_to_hide = require("modules.click_to_hide")
        local w = make_widget("test")
        click_to_hide.popup(w, function() end, { enable_escape = false })
        w.visible = true
        w:emit("property::visible", w)
        assert.falsy(get_keygrabber_active())
    end)

    runner.it("is_any_visible returns true when any registered popup is visible", function()
        reset_state()
        local click_to_hide = require("modules.click_to_hide")
        local w = make_widget("test")
        click_to_hide.popup(w, function() end)
        assert.falsy(click_to_hide.is_any_visible())
        w.visible = true
        assert.truthy(click_to_hide.is_any_visible())
    end)

    runner.it("unregister removes a popup", function()
        reset_state()
        local click_to_hide = require("modules.click_to_hide")
        local w = make_widget("test")
        click_to_hide.popup(w, function() end)
        click_to_hide.unregister(w)
        assert.falsy(click_to_hide.is_any_visible())
    end)

    runner.it("hide_all hides every registered popup", function()
        reset_state()
        local click_to_hide = require("modules.click_to_hide")
        local w1, w2 = make_widget("a"), make_widget("b")
        local h1, h2 = false, false
        click_to_hide.popup(w1, function() h1 = true end)
        click_to_hide.popup(w2, function() h2 = true end)
        click_to_hide.hide_all()
        assert.truthy(h1)
        assert.truthy(h2)
    end)
end)
