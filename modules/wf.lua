local M = {};

local known_networks={
    {ssid='Rotlis iPhone',pwd=encoder.fromBase64('VHJ1Ym9yZy03'),auto=true},
    {ssid='rotlis',pwd=encoder.fromBase64('WmFib2RheUVnb01hemF5'),auto=true},
    {ssid='rotlis2',pwd=encoder.fromBase64('WmFib2RheUVnb01hemF5'),auto=true},
    {ssid='hackathon',pwd=encoder.fromBase64('aGFja2F0aG9u'),auto=true}
--    {ssid='innovate',pwd=nil,auto=true}
}

local wf_timer = tmr.create()
function M.startScan()

    local function scan()
        wifi.sta.getap(function(t)
            if nil ~= next(t) then
               openNetworks = {}
               bestRsi = -99
               bestNetwork = nil

               for ssid,v in pairs(t) do
                 wp,sg,mc,ch = string.match(v, '(.+),(.+),(.+),(.+)')
                 sg = tonumber(sg)

                 -- check if cueent network is known and has better signal among all known
                 for _,network in pairs(known_networks) do
                    if ssid == network['ssid'] then
                         print(ssid.."|"..sg)
                        if sg~=nil and sg > bestRsi then
                            bestRsi=sg
                            bestNetwork = network
                        end

                    end
                 end --for

                 if '0' == wp then
                    openNetworks[ssid] = sg
                    print(ssid..'~'..sg)
--                                print(openNetworks)
                 end
               end --for

              -- new way WIP

                    -- get best network out from currenlty seen
                    -- if currenlty connected to home and best network is other home which is 10 beter then
                    --  connect to best home network
                    -- end

                    -- if currently connected to open network and best network is home then
                    --  connect to best home network
                    -- end

                    -- if not connected and best network is open then
                    --  connect to open network
                    -- end


-- old way.. works
              if (bestNetwork~=nil) then
                 print("best network:"..bestNetwork['ssid'])
                 if wifi.sta.status() == wifi.STA_GOTIP and wifi.sta.getip() ~= nil then
                     local currIp,nm=wifi.sta.getip()
                     local curr_sta_config=wifi.sta.getconfig(true)
                     local currRsi=wifi.sta.getrssi()
                     local currSsid=curr_sta_config.ssid
                     local isCurrOpen=curr_sta_config.pwd==nil

                     --TODO: check if current connection is for open network
                     print("currently connected to:"..currSsid.." with rsi:"..currRsi.." ip:"..currIp)
                     if curr_sta_config.ssid~=bestNetwork['ssid'] and bestRsi>(currRsi+10) then
                        print("$$$$$ reconnecting to better network..")
                        wifi.sta.config(bestNetwork)
                        wifi.sta.connect()
                     end
                 else
                    print("@@@@@ not connected yet anywhere. Connecting..")

                    wifi.sta.config(bestNetwork)
                    wifi.sta.connect()
                 end
              else -- no home networks found
                print("No home networks found")

                if wifi.sta.status() == wifi.STA_GOTIP and wifi.sta.getip() ~= nil then
                    print("Already connected to "..wifi.sta.getconfig(true).ssid..". Dont need to do anything.")
                elseif next(openNetworks) ~= nil then
                    for ssid,rsi in pairs(openNetworks) do
                        print("No current connection. Will try to connect to open net "..ssid)
--                        wifi.sta.disconnect()
                        wifi.sta.config({ssid=ssid,pwd=nil,auto=false})
                        wifi.sta.connect()
                        break --for
                    end
                else
                    print("No open networks found. Give up.")
                end
                -- list
              end
--- end of old way
            end
        end)
    end


    wf_timer:register(WIFI_SCAN_INTERVAL_MS, tmr.ALARM_AUTO, scan)


    wifi.sta.eventMonReg(wifi.STA_IDLE, function() print("wifi.STA_IDLE") end)
    wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() print("wifi.STA_CONNECTING") end)
    wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() print("wifi.STA_WRONGPWD") end)
    wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() print("wifi.STA_APNOTFOUND") end)
    wifi.sta.eventMonReg(wifi.STA_FAIL, function() print("wifi.STA_FAIL") end)
    wifi.sta.eventMonReg(wifi.STA_GOTIP, function() print("wifi.STA_GOTIP") end)
    wifi.sta.eventMonStart()

    scan()
    wf_timer:start()
end


return M

