--  _______         __   __   ___ __              __   __
-- |    |  |.-----.|  |_|__|.'  _|__|.----.---.-.|  |_|__|.-----.-----.-----.
-- |       ||  _  ||   _|  ||   _|  ||  __|  _  ||   _|  ||  _  |     |__ --|
-- |__|____||_____||____|__||__| |__||____|___._||____|__||_____|__|__|_____|
--  ______                     __
-- |   __ \.---.-.-----.-----.|  |
-- |    __/|  _  |     |  -__||  |
-- |___|   |___._|__|__|_____||__|
-- ------------------------------------------------- --
-- -------------- variable assignment -------------- --
local emptyCenter = require('ui.notifications.notification_center.notifications_center.empty')
local width = dpi(410)
local overflow = require("utilities.overflow")
local notificationsEmpty = true
-- ------------------------------------------------- --
-- NOTE signal to indicate empty notifications for changing wibar icon
awesome.emit_signal('notificationsEmpty:true')
-- ------------------------------------------------- --
-- ---------------- panel variables ---------------- --
local panelLayout = wibox.container.scroll.vertical

panelLayout.spacing = dpi(7)
panelLayout.forced_width = width
-- ------------------------------------------------- --
-- NOTE reset the panel for when notifications are present vs. absent
resetPanelLayout = function()
    panelLayout:reset(panelLayout)
    panelLayout:insert(1, emptyCenter)
    notificationsEmpty = true
    awesome.emit_signal('notificationsEmpty:true')
end
-- ------------------------------------------------- --
-- NOTE remove element for when notifications are absent
removeElement = function(box)
    panelLayout:remove_widgets(box)

    if #panelLayout.children == 0 and notificationsEmpty == false then
        panelLayout:reset(panelLayout)
        panelLayout:insert(1, emptyCenter)
        notificationsEmpty = true
        awesome.emit_signal('notificationsEmpty:true')
    end
end

panelLayout:insert(1, emptyCenter)
-- ------------------------------------------------- --
-- NOTE  notification signal fpr when one is added
naughty.connect_signal(
    'added',
    function(n)
        if #panelLayout.children == 1 and notificationsEmpty then
            panelLayout:reset(panelLayout)
            notificationsEmpty = false
            awesome.emit_signal('notificationsEmpty:false')
        end
        local box = require('widget.notification_center.elements')
        panelLayout:insert(1, box.create(n.title, n.message))
        awesome.emit_signal('notificationsEmpty:false')
    end
)
-- ------------------------------------------------- --
return panelLayout
