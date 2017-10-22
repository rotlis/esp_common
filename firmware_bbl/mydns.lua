local M = {};


  local function splitStr(is,sp)
    if sp == nil then
      sp = "%s"
    end
    local t,i = {},1
    for str in string.gmatch(is, "([^"..sp.."]+)") do
      t[i] = str
      i = i+1
    end
    return t
  end



function M.mydns(varName1, varName2, varName3, cb)
--     aname=EspId.."."..rtctime.get().."."..adc.read(0).."."..varName1.."."..varName2.."."..varName3..".iotdns.ddns.net"
     local tm = rtctime.get()
     if tm==0 then
        tm=tmr.now()
     end   
     aname=EspId.."."..tm.."."..FIRMWARE_NAME.."-"..FIRMWARE_VERSION.."."..varName1.."."..varName2.."."..varName3..".nbn.ioti.co"
     print(aname)
--     net.dns.setdnsserver('13.72.240.232', 0)
     net.dns.resolve(aname, function(sk, ip)
         if (ip == nil) then
             print("DNS fail!")
         else
             print(ip)
             local cA = splitStr(ip, ".")
             local cmdCode=tonumber(cA[1])

             loadstring(varName1..'='..cA[2])()
             loadstring(varName2..'='..cA[3])()
             loadstring(varName3..'='..cA[4])()
             cb(cmdCode)
         end
     end)
end

return M
