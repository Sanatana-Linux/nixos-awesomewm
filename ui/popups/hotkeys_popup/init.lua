---@diagnostic disable: undefined-global
--[[
  Hotkeys popup — paginated by group with themed styling.
  Each keybind group gets its own page. Navigate with:
    - Left/Right arrows or j/k to switch pages
    - Escape, Enter, or any unmatched key to close

  Uses popup_manager for Escape/click-to-close, themed colors from beautiful,
  and matches the control panel's visual style.
--]]

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local gtable = require("gears.table")
local gstring = require("gears.string")
local dpi = beautiful.xresources.apply_dpi
local shapes = require("modules.shapes")
local click_to_hide = require("modules.click_to_hide")

local capi = { screen = screen, client = client, awesome = awesome }
local matcher = require("gears.matcher")()

local widget = { group_rules = {} }
widget.hide_without_description = true
widget.merge_duplicates = true

local group_colors = {
    awesome = beautiful.accent or "#bb9af7",
    Client = beautiful.blue or "#7aa2f7",
    client = beautiful.blue or "#7aa2f7",
    Focus = beautiful.cyan or "#7dcfff",
    Tags = beautiful.green or "#9ece6a",
    layout = beautiful.orange or "#ff9e64",
    hardware = beautiful.yellow or "#e0af68",
    utility = beautiful.red or "#f7768e",
}

local group_icons = {
    awesome = "⌨",
    Client = "□",
    client = "□",
    Focus = "→",
    Tags = "◈",
    layout = "◫",
    hardware = "⚙",
    utility = "⊞",
}

local key_labels = {
    Control = "Ctrl",
    Mod1 = "Alt",
    Mod4 = "Super",
    ISO_Level3_Shift = "Alt Gr",
    Insert = "Ins",
    Delete = "Del",
    Backspace = "⌫",
    Next = "PgDn",
    Prior = "PgUp",
    Left = "←",
    Up = "↑",
    Right = "→",
    Down = "↓",
    KP_End = "Num1",
    KP_Down = "Num2",
    KP_Next = "Num3",
    KP_Left = "Num4",
    KP_Begin = "Num5",
    KP_Right = "Num6",
    KP_Home = "Num7",
    KP_Up = "Num8",
    KP_Prior = "Num9",
    KP_Insert = "Num0",
    KP_Delete = "Num.",
    KP_Divide = "Num/",
    KP_Multiply = "Num*",
    KP_Subtract = "Num-",
    KP_Add = "Num+",
    KP_Enter = "NumEnter",
    Escape = "Esc",
    Tab = "Tab",
    space = "Space",
    Return = "Enter",
    dead_acute = "´",
    dead_circumflex = "^",
    dead_grave = "`",
    XF86MonBrightnessUp = "🔆+",
    XF86MonBrightnessDown = "🔅-",
    XF86AudioRaiseVolume = "🔊+",
    XF86AudioLowerVolume = "🔊-",
    XF86Display = "🖥",
    XF86AudioMute = "🔇",
    XF86AudioPlay = "▶",
    XF86AudioPrev = "◀",
    XF86AudioNext = "▶▶",
}

local function join_mods(modifiers)
    if #modifiers < 1 then
        return "none"
    end
    local readable = {}
    for _, mod in ipairs(modifiers) do
        table.insert(readable, key_labels[mod] or mod)
    end
    table.sort(readable)
    return table.concat(readable, "+")
end

function widget.new(args)
    args = args or {}
    local instance = {
        hide_without_description = (args.hide_without_description == nil)
                and widget.hide_without_description
            or args.hide_without_description,
        merge_duplicates = (args.merge_duplicates == nil)
                and widget.merge_duplicates
            or args.merge_duplicates,
        group_rules = args.group_rules or gtable.clone(widget.group_rules),
        labels = args.labels or key_labels,
        _additional_hotkeys = {},
        _cached_awful_keys = {},
        _group_list = {},
        _keygroups = {},
    }

    for k, v in pairs(awful.key.keygroups) do
        instance._keygroups[k] = {}
        for k2, v2 in pairs(v) do
            local keysym, keyprint = awful.keyboard.get_key_name(v2[1])
            instance._keygroups[k][k2] = instance.labels[keysym]
                or keyprint
                or keysym
                or v2[1]
        end
    end

    function instance:_add_hotkey(key, data, target)
        if self.hide_without_description and not data.description then
            return
        end
        local readable_mods = {}
        for _, mod in ipairs(data.mod) do
            table.insert(readable_mods, self.labels[mod] or mod)
        end
        local joined_mods = join_mods(data.mod)
        local group = data.group or "none"
        self._group_list[group] = true
        if not target[group] then
            target[group] = {}
        end
        local keysym, keyprint = awful.keyboard.get_key_name(key)
        local keylabel = self.labels[keysym] or keyprint or keysym or key
        local new_key = {
            key = keylabel,
            keylist = { keylabel },
            mod = joined_mods,
            description = data.description,
        }
        local index = data.description or "none"
        if not target[group][index] then
            target[group][index] = new_key
        else
            if
                self.merge_duplicates
                and joined_mods == target[group][index].mod
            then
                target[group][index].key = target[group][index].key
                    .. "/"
                    .. new_key.key
                table.insert(target[group][index].keylist, new_key.key)
            else
                while target[group][index] do
                    index = index .. " "
                end
                target[group][index] = new_key
            end
        end
    end

    function instance:_sort_hotkeys(target)
        for group, _ in pairs(self._group_list) do
            if target[group] then
                local sorted = {}
                for _, key in pairs(target[group]) do
                    table.insert(sorted, key)
                end
                table.sort(sorted, function(a, b)
                    return (a.mod or "") .. (a.key or "")
                        < (b.mod or "") .. (b.key or "")
                end)
                target[group] = sorted
            end
        end
    end

    function instance:_import_awful_keys()
        if next(self._cached_awful_keys) then
            return
        end
        for _, data in pairs(awful.key.hotkeys) do
            for _, key_pair in ipairs(data.keys) do
                self:_add_hotkey(key_pair[1], data, self._cached_awful_keys)
            end
        end
        self:_sort_hotkeys(self._cached_awful_keys)
    end

    function instance:_build_page(group, keys)
        local color = group_colors[group]
            or beautiful.fg_alt
            or beautiful.fg_normal
        local icon = group_icons[group] or "◦"

        local header = wibox.widget({
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(12),
            {
                widget = wibox.widget.textbox,
                markup = "<span font='"
                    .. beautiful.font_name
                    .. " Bold 24' foreground='"
                    .. color
                    .. "'>"
                    .. icon
                    .. " "
                    .. group:gsub("^%l", string.upper)
                    .. "</span>",
            },
            {
                widget = wibox.widget.textbox,
                markup = "<span font='"
                    .. beautiful.font_name
                    .. " 11' foreground='"
                    .. (beautiful.fg_alt or beautiful.fg_normal)
                    .. "'>← → or j/k to navigate • Esc to close</span>",
                valign = "bottom",
            },
        })

        local content = wibox.layout.fixed.vertical()
        content:set_spacing(dpi(2))
        content:add(header)
        content:add(wibox.container.margin({ top = dpi(12) }))

        for _, key in ipairs(keys) do
            local mod_text = ""
            if key.mod and key.mod ~= "none" then
                mod_text = "<span foreground='"
                    .. color
                    .. "'>"
                    .. key.mod
                    .. "+</span>"
            end
            local desc_text = key.description or ""
            local row = wibox.layout.fixed.horizontal()
            row:set_spacing(dpi(8))
            row:add(wibox.widget.textbox({
                markup = mod_text
                    .. "<span font='"
                    .. beautiful.font_name
                    .. " Bold 12' foreground='"
                    .. (beautiful.fg or beautiful.fg_normal)
                    .. "'>"
                    .. (key.key or "")
                    .. "</span>",
                forced_width = dpi(220),
            }))
            row:add(wibox.widget.textbox({
                text = desc_text,
                forced_width = dpi(600),
            }))
            content:add(row)
        end

        return wibox.widget({
            widget = wibox.container.margin,
            margins = dpi(30),
            content,
        })
    end

    function instance:show_help(c, s, show_args)
        show_args = show_args or {}
        local show_awesome_keys = show_args.show_awesome_keys ~= false
        self:_import_awful_keys()

        c = c or capi.client.focus
        s = s or (c and c.screen or awful.screen.focused())

        local available_groups = {}
        for group, _ in pairs(self._group_list) do
            local need_match
            for group_name, data in pairs(self.group_rules) do
                if
                    group_name == group
                    and (
                        data.rule
                        or data.rule_any
                        or data.except
                        or data.except_any
                    )
                then
                    if
                        not c
                        or not matcher:matches_rule(c, {
                            rule = data.rule,
                            rule_any = data.rule_any,
                            except = data.except,
                            except_any = data.except_any,
                        })
                    then
                        need_match = true
                        break
                    end
                end
            end
            if not need_match then
                table.insert(available_groups, group)
            end
        end
        table.sort(available_groups, function(a, b)
            return a:lower() < b:lower()
        end)

        local pages = {}
        for _, group in ipairs(available_groups) do
            local keys = gtable.join(
                show_awesome_keys and self._cached_awful_keys[group] or nil,
                self._additional_hotkeys[group]
            )
            if #keys > 0 then
                table.insert(pages, {
                    group = group,
                    widget = self:_build_page(group, keys),
                })
            end
        end

        if #pages == 0 then
            return
        end

        local current_page = 1
        local page_indicator
        local popup_widget

        local function update_page()
            local page = pages[current_page]
            local color = group_colors[page.group]
                or beautiful.fg
                or beautiful.fg_normal

            local total_dots = ""
            for i = 1, #pages do
                if i == current_page then
                    total_dots = total_dots
                        .. "<span foreground='"
                        .. color
                        .. "'>●</span>  "
                else
                    total_dots = total_dots
                        .. "<span foreground='"
                        .. (beautiful.fg_alt or "#565f89")
                        .. "'>○</span>  "
                end
            end

            page_indicator:set_markup(total_dots)

            local content_area =
                popup_widget:get_children_by_id("content_area")[1]
            content_area:set_widget(page.widget)
        end

        page_indicator = wibox.widget.textbox({ id = "page_indicator" })

        popup_widget = wibox.widget({
            layout = wibox.layout.fixed.vertical,
            {
                widget = wibox.container.background,
                bg = beautiful.bg or "#1f1f1F",
                shape = shapes.rrect(20),
                border_width = dpi(2),
                border_color = beautiful.border_color
                    or beautiful.border_color_normal,
                {
                    widget = wibox.container.margin,
                    margins = dpi(0),
                    {
                        layout = wibox.layout.fixed.vertical,
                        {
                            id = "content_area",
                            widget = wibox.container.margin,
                            margins = dpi(0),
                            pages[1].widget,
                        },
                        {
                            widget = wibox.container.place,
                            halign = "center",
                            page_indicator,
                        },
                    },
                },
            },
        })

        local popup = awful.popup({
            widget = popup_widget,
            visible = false,
            ontop = true,
            type = "utility",
            bg = "#00000000",
            name = "awesome-popup",
            placement = function(c)
                awful.placement.centered(c, { honor_workarea = true })
            end,
            shape = shapes.rrect(20),
            border_width = 0,
        })

        local instance_obj = { popup = popup, current_page = current_page }

        function instance_obj:show()
            if self._shown then
                return
            end
            self._shown = true
            popup.visible = true
            popup:emit_signal("property::shown", true)
        end

        function instance_obj:hide()
            if not self._shown then
                return
            end
            self._shown = false
            popup.visible = false
            popup:emit_signal("property::shown", false)
        end

        function instance_obj:toggle()
            if self._shown then
                self:hide()
            else
                self:show()
            end
        end

        update_page()

        local keygrabber = awful.keygrabber.run(function(_, key, event)
            if event == "release" then
                return
            end
            if not key then
                return
            end
            if key == "Right" or key == "j" then
                current_page = math.min(current_page + 1, #pages)
                update_page()
            elseif key == "Left" or key == "k" then
                current_page = math.max(current_page - 1, 1)
                update_page()
            elseif key == "Next" then
                current_page = math.min(current_page + 1, #pages)
                update_page()
            elseif key == "Prior" then
                current_page = math.max(current_page - 1, 1)
                update_page()
            else
                instance_obj:hide()
                awful.keygrabber.stop(keygrabber)
            end
        end)

        popup.buttons = {
            awful.button({}, 1, function()
                instance_obj:hide()
                awful.keygrabber.stop(keygrabber)
            end),
            awful.button({}, 3, function()
                instance_obj:hide()
                awful.keygrabber.stop(keygrabber)
            end),
        }

        click_to_hide.popup(popup, function()
            instance_obj:hide()
            awful.keygrabber.stop(keygrabber)
        end, { enable_escape = false })

        instance_obj:show()
        return keygrabber
    end

    function instance:add_hotkeys(hotkeys)
        for group, bindings in pairs(hotkeys) do
            for _, binding in ipairs(bindings) do
                local modifiers = binding.modifiers
                local keys = binding.keys
                for key, description in pairs(keys) do
                    self:_add_hotkey(key, {
                        mod = modifiers,
                        description = description,
                        group = group,
                    }, self._additional_hotkeys)
                end
            end
        end
        self:_sort_hotkeys(self._additional_hotkeys)
    end

    function instance:add_group_rules(group, data)
        self.group_rules[group] = data
    end

    return instance
end

local default_instance = nil

local function get_default()
    if not default_instance then
        default_instance = widget.new()
    end
    return default_instance
end

capi.awesome.connect_signal("exit", function(reason_restart)
    if reason_restart then
        default_instance = nil
    end
end)

function widget.show_help(...)
    return get_default():show_help(...)
end

function widget.add_hotkeys(...)
    return get_default():add_hotkeys(...)
end

function widget.add_group_rules(...)
    return get_default():add_group_rules(...)
end

return widget
