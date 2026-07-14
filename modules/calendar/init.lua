--- Calendar widget.
-- Instantiable (uses the `setmetatable __call` pattern, not singleton — you can
-- create multiple calendars). Supports month navigation, day selection, and
-- optional Hebrew-format weekday layout. Backed by `wibox.widget` so it can
-- be embedded inside any container.
-- @module modules.calendar

local awful = require("awful")
local wibox = require("wibox")
local gtable = require("gears.table")
local beautiful = require("beautiful")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi

local calendar = {}

local hebr_format = {
    [1] = 7,
    [2] = 1,
    [3] = 2,
    [4] = 3,
    [5] = 4,
    [6] = 5,
    [7] = 6,
}

--- Build a single weekday header cell (Mon, Tue, ...).
-- @tparam table self The calendar instance (for `_private` access)
-- @tparam number index 1..7 weekday index
-- @treturn table A wibox widget
local function wday_widget(self, index)
    local wp = self._private
    return wibox.widget({
        widget = wibox.container.background,
        fg = index >= 6 and wp.weekend_fg or wp.fg,
        {
            widget = wibox.container.margin,
            margins = dpi(10),
            {
                widget = wibox.widget.textbox,
                align = "center",
                font = beautiful.font_name .. dpi(9),
                markup = os.date(
                    "%a",
                    os.time({
                        year = 1,
                        month = 1,
                        day = index,
                    })
                ),
            },
        },
    })
end

--- Build a single day cell.
-- Colours come from the per-state `_*_fg`/`_*_bg` `_private` fields
-- (priority: current > another-month > default).
-- @tparam table self The calendar instance
-- @tparam number|string day Day-of-month (1..31)
-- @tparam boolean is_current Whether this is today's date
-- @tparam boolean is_another_month Whether this day belongs to prev/next month
-- @treturn table A wibox widget
local function day_widget(self, day, is_current, is_another_month)
    local wp = self._private
    local fg_color = (
        (is_current and wp.current_day_fg)
        or (is_another_month and wp.another_month_fg)
    ) or wp.day_fg
    local bg_color = (
        (is_current and wp.current_day_bg)
        or (is_another_month and wp.another_month_bg)
    ) or wp.day_bg

    return wibox.widget({
        widget = wibox.container.background,
        fg = fg_color,
        bg = bg_color,
        shape = wp.day_shape,
        {
            widget = wibox.container.margin,
            margins = dpi(10),
            {
                widget = wibox.widget.textbox,
                align = "center",
                markup = day,
            },
        },
    })
end

--- Switch the calendar to a different month/year. Re-renders the day grid.
-- @tparam table date `{year=N, month=N, day=N}` like `os.date("*t")`
function calendar:set_date(date)
    local wp = self._private
    local days_layout = self:get_children_by_id("days-layout")[1]
    local title_textbox = self:get_children_by_id("title-textbox")[1]
    days_layout:reset()

    wp.date = date
    local curr_date = os.date("*t")
    local firstday = os.date(
        "*t",
        os.time({
            year = date.year,
            month = date.month,
            day = 1,
        })
    )
    local lastday = os.date(
        "*t",
        os.time({
            year = date.year,
            month = date.month + 1,
            day = 0,
        })
    )
    local month_count = lastday.day
    local month_start = not wp.sun_start and hebr_format[firstday.wday]
        or firstday.wday
    local rows =
        math.max(5, math.min(6, 5 - (36 - (month_start + month_count))))
    local month_prev_lastday = os.date(
        "*t",
        os.time({
            year = date.year,
            month = date.month,
            day = 0,
        })
    ).day
    local month_prev_count = month_start - 1
    local month_next_count = rows * 7 - lastday.day - month_prev_count

    title_textbox:set_markup(os.date("%B, %Y", os.time(date)))

    for day = month_prev_lastday - (month_prev_count - 1), month_prev_lastday, 1 do
        days_layout:add(day_widget(self, day, false, true))
    end

    for day = 1, month_count, 1 do
        local is_current = day == curr_date.day
            and date.month == curr_date.month
            and date.year == curr_date.year
        days_layout:add(day_widget(self, day, is_current, false))
    end

    for day = 1, month_next_count, 1 do
        days_layout:add(day_widget(self, day, false, true))
    end
end

--- Step the calendar forward or backward by one month.
-- @tparam number dir +1 (next month) or -1 (previous month)
function calendar:inc(dir)
    local wp = self._private
    local new_calendar_month = wp.date.month + dir
    self:set_date({
        year = wp.date.year,
        month = new_calendar_month,
        day = wp.date.day,
    })
end

--- Reset the calendar view to the current system date.
function calendar:set_current_date()
    self:set_date(os.date("*t"))
end

--- Construct a new calendar widget.
-- Sets up the title, weekday headers, prev/next buttons, and renders
-- the current month. The widget is instantiable (not a singleton).
-- @tparam[opt] table args Configuration:
--   * `shape` (function): outer shape
--   * `day_shape` (function): per-day cell shape
--   * `margins` (number|table): outer margins (default `dpi(20)`)
--   * `sun_start` (boolean): if true, week starts on Sunday (default
--     is Monday — Hebrew / ISO layout)
--   * `bg` (string): outer background
--   * `day_fg`/`day_bg` (string): default day colours
--   * `current_day_fg`/`current_day_bg` (string): today's colours
--   * `current_month_fg`/`current_month_bg` (string): this month
--   * `another_month_fg`/`another_month_bg` (string): other months
--   * `weekend_fg` (string): weekend (Sat/Sun) header colour
-- @treturn table A wibox widget with set_date/inc/set_current_date methods
local function new(args)
    args = args or {}
    local ret = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg_alt,
        shape = args.shape,
        {
            widget = wibox.container.margin,
            margins = args.margins or dpi(20),
            {
                layout = wibox.layout.fixed.vertical,
                {
                    layout = wibox.layout.align.horizontal,
                    {
                        id = "title-background",
                        widget = wibox.container.background,
                        {
                            id = "title-textbox",
                            widget = wibox.widget.textbox,
                            align = "center",
                        },
                    },
                    nil,
                    {
                        widget = wibox.layout.fixed.horizontal,
                        spacing = dpi(20),
                        {
                            id = "dec-button",
                            widget = wibox.container.background,
                            {
                                widget = wibox.widget.textbox,
                                markup = text_icons.arrow_left,
                            },
                        },
                        {
                            id = "inc-button",
                            widget = wibox.container.background,
                            {
                                widget = wibox.widget.textbox,
                                markup = text_icons.arrow_right,
                            },
                        },
                    },
                },
                {
                    id = "wdays-layout",
                    layout = wibox.layout.flex.horizontal,
                },
                {
                    id = "days-layout",
                    layout = wibox.layout.grid,
                    forced_num_cols = 7,
                    expand = true,
                    forced_height = dpi(230),
                },
            },
        },
    })

    gtable.crush(ret, calendar, true)
    local wp = ret._private

    wp.sun_start = args.sun_start
    wp.margins = args.margins
    wp.shape = args.shape
    wp.day_shape = args.day_shape
    wp.bg = args.bg or beautiful.bg_alt
    wp.day_fg = args.day_fg or beautiful.fg
    wp.day_bg = args.day_bg or beautiful.bg_alt
    wp.current_day_fg = args.current_day_fg or beautiful.bg
    wp.current_day_bg = args.current_day_bg or beautiful.ac
    wp.current_month_fg = args.current_month_fg or beautiful.fg
    wp.current_month_bg = args.current_month_bg or beautiful.bg_alt
    wp.another_month_fg = args.another_month_fg or beautiful.fg_alt
    wp.another_month_bg = args.another_month_bg or beautiful.bg_alt
    wp.weekend_fg = args.weekend_fg or beautiful.red

    local wdays_layout = ret:get_children_by_id("wdays-layout")[1]

    for i = 1, 7 do
        wdays_layout:add(
            wp.sun_start and wday_widget(ret, hebr_format[i])
                or wday_widget(ret, i)
        )
    end

    local title_background = ret:get_children_by_id("title-background")[1]
    local dec_button = ret:get_children_by_id("dec-button")[1]
    local inc_button = ret:get_children_by_id("inc-button")[1]

    title_background:buttons({
        awful.button({}, 1, function()
            ret:set_current_date()
        end),
    })

    dec_button:buttons({
        awful.button({}, 1, function()
            ret:inc(-1)
        end),
    })

    inc_button:buttons({
        awful.button({}, 1, function()
            ret:inc(1)
        end),
    })

    for _, item in ipairs({
        title_background,
        dec_button,
        inc_button,
    }) do
        item:connect_signal("mouse::enter", function(w)
            w:set_fg(beautiful.ac)
        end)
        item:connect_signal("mouse::leave", function(w)
            w:set_fg(beautiful.fg)
        end)
        item:connect_signal("button::press", function(w)
            w:set_fg(beautiful.fg)
        end)
    end

    ret:set_current_date()

    return ret
end

return setmetatable({
    new = new,
}, {
    __call = function(_, ...)
        return new(...)
    end,
})
