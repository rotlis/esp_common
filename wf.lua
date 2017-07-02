local moduleName = ...
local M = {}
_G[moduleName] = M

function M.connect(callback)
-- home network for loading updates
--  local apSSID = 'wifitag0'
--  local apPSWD = 'wifitag1'

--  local apSSID = 'Rotlis iPhone'
--  local apPSWD = 'Truborg-7'
--  local apSSID = 'IPTP'
--  local apPSWD = 'wifi4787'

local apSSID = 'd99ad2'
local apPSWD = '271056217'

  local function stopMonitor(err)
    tmr.stop(0)
    wifi.sta.eventMonStop()
    wifi.sta.eventMonReg(wifi.STA_GOTIP, "unreg")
    callback(err)
  end

  local function getlist(APs)
    local fnd = false
    if nil ~= next(APs) then
      for k,v in pairs(APs) do
        if apSSID == k then
          fnd = true
          break
        end
      end
      -- if our home SSID is in the list try to connect to it
      if fnd then
        wifi.sta.config(apSSID,apPSWD)
        print("Connecting to",apSSID)
        tmr.alarm(0,20000,tmr.ALARM_SINGLE,function()
          stopMonitor("Can not connect to "..apSSID)
        end)
      else
        stopMonitor("No wifitag AP")
      end
    else
      stopMonitor("No available APs")
    end
  end

  wifi.setmode(wifi.STATION)
  wifi.sta.disconnect()
  wifi.sta.eventMonReg(wifi.STA_GOTIP, function() stopMonitor() end)
  wifi.sta.eventMonStart()
  wifi.sta.getap(getlist)
end

return M
