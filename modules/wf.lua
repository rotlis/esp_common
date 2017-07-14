local M = {};

local known_networks={
    {ssid='Rotlis iPhone',pwd=encoder.fromBase64('VHJ1Ym9yZy03'),auto=true},
    {ssid='rotlis',pwd=encoder.fromBase64('WmFib2RheUVnb01hemF5'),auto=true},
    {ssid='rotlis2',pwd=encoder.fromBase64('WmFib2RheUVnb01hemF5'),auto=true},
    {ssid='hackathon',pwd=encoder.fromBase64('aGFja2F0aG9u'),auto=true},
    {ssid='innovate',pwd='',auto=true}
}

function M.scan(cb)
    wifi.sta.getap(function(t)
        if nil ~= next(t) then
           bestRsi = -99
           bestNetwork = nil
           for ssid,v in pairs(t) do
             wp,sg,mc,ch = string.match(v, '(.+),(.+),(.+),(.+)')
             sg = tonumber(sg)
--             if sg == nil or sg < -99 then
--               sg = -99
--             end

             for _,network in pairs(known_networks) do
                if ssid == network['ssid'] then
                     print(ssid.."|"..sg)
                    if sg > bestRsi then
                        bestRsi=sg
                        bestNetwork = network
                    end
                end
             end
           end --for


          if (bestNetwork~=nil) then
             print("best network:"..bestNetwork['ssid'])
             if wifi.sta.status() == wifi.STA_GOTIP and wifi.sta.getip() ~= nil then
                 local currIp,nm=wifi.sta.getip()
                 local curr_sta_config=wifi.sta.getconfig(true)
                 local currRsi=wifi.sta.getrssi()
                 print("currently connected to:"..curr_sta_config.ssid.." with rsi:"..currRsi.." ip:"..currIp)
                 if curr_sta_config.ssid~=bestNetwork['ssid'] and bestRsi>(currRsi+10) then
                    print("$$$$$ reconnecting to better network..")
                    wifi.sta.config(bestNetwork)
                 end
             else
                print("@@@@@ not connected yet anywhere. Connecting..")

                wifi.sta.config(bestNetwork)
             end

          else
             print("No known networks found")
          end
        end
    end)
end


return M

