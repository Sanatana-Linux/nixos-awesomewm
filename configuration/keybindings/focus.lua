--  _______
-- |    ___|.-----.----.--.--.-----.
-- |    ___||  _  |  __|  |  |__ --|
-- |___|    |_____|____|_____|_____|
-- -------------------------------------------------------------------------- --
--
awful.keyboard.append_global_keybindings({
    -- -------------------------------------------------------------------------- --
    --
    awful.key({ modkey }, "j", function()
        awful.client.focus.byidx(1)
    end, { description = "focus next by index", group = "Focus" }),
    -- -------------------------------------------------------------------------- --
    --
    awful.key({ modkey }, "k", function()
        awful.client.focus.byidx(-1)
    end, { description = "focus previous by index", group = "Focus" }),
    -- -------------------------------------------------------------------------- --
    --
    awful.key({ modkey, "Control" }, "j", function()
        awful.screen.focus_relative(1)
    end, { description = "focus the next screen", group = "Focus" }),
    -- -------------------------------------------------------------------------- --
    --
    awful.key({ modkey, "Control" }, "k", function()
        awful.screen.focus_relative(-1)
    end, { description = "focus the previous screen", group = "Focus" }),
    -- -------------------------------------------------------------------------- --
    --
    awful.key({ modkey, "Control" }, "n", function()
        local c = awful.client.restore()
        if c then
            c:activate({ raise = true, context = "key.unminimize" })
        end
    end, { description = "restore minimized", group = "Focus" }),
})
