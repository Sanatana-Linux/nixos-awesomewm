--  ______                     __
-- |   __ \.---.-.-----.-----.|  |
-- |    __/|  _  |     |  -__||  |
-- |___|   |___._|__|__|_____||__|
-- ------------------------------------------------- --

local searching = require("widgets.popups.network.widgets.searching")
local width = dpi(450)

local panelLayout = modules.overflow.vertical()

panelLayout.spacing = dpi(7)
panelLayout.forced_width = width

local resetDevicePanelLayout = function()
    panelLayout:reset(panelLayout)
end

local networksAdd = function(n)
    local box = require("widgets.popups.network.widgets.elements")
    panelLayout:insert(
        #panelLayout.children + 1,
        box.create(
            n.SSID,
            n.BSSID,
            n.connectStatus,
            n.signal,
            n.secure,
            n.speed
        )
    )
end

local networksRemove = function(box)
    panelLayout:remove_widgets(box)
end

awesome.connect_signal("network::networks:refreshPanel", function()
    resetDevicePanelLayout()
    panelLayout:insert(1, searching)
    local searchStatus = true
    awful.spawn.with_line_callback(
        [[bash -c "nmcli -g in-use,signal,security,rate,BSSID,SSID d wifi list | sed -e 's/^ /no/g; s/\*/yes/g; s/::/:no:/g; s/:/;/g'"]],
        {
            stdout = function(line)
                local results = {}
                line = line:gsub("\\;", ":")
                for match in (line .. ";"):gmatch("(.-)" .. ";") do
                    table.insert(results, match)
                end
                if #panelLayout.children == 1 and searchStatus then
                    resetDevicePanelLayout()
                end
                if (#panelLayout.children < 14) and results[6] ~= "" then
                    searchStatus = false
                    networksAdd({
                        connectStatus = results[1],
                        signal = results[2],
                        secure = results[3],
                        speed = results[4],
                        BSSID = results[5],
                        SSID = results[6],
                    })
                end
            end,
        }
    )
end)

return panelLayout
