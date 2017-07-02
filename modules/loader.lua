dSLP = 60
aNTP = "pool.ntp.org"

loadList = "update_list"
fmwTool = "fmw.lua"
fmwAddr = ""
fmwMod = nil
fmwVer = nil

function deepSl()
  print("deepSl")
  rtctime.dsleep(dSLP*1000000)
end

function OKCh(unix)
  if fmwMod ~= nil then
    file.open(EspId, "w")
    file.write(fmwMod)
    file.close()
  end
  if fmwVer ~= nil then
    file.open("_VER", "w")
    file.write(fmwVer)
    file.close()
  end
  if unix ~= nil then
    print('time is syncronized and saved...')
    file.open("_TIME", "w")
    file.write(unix)
    file.close()
  end
  print('firmware is updated, restarting...')
  rtctime.dsleep(0)
end

function loadUpdate()
  local fl = require("fl")
  local pti,ptj = string.find(fmwTool,'%.')
  local fmwpack = string.sub(fmwTool, 1, pti-1)
  local fmw = require(fmwpack)
  local function syncTime()
    sntp.sync(aNTP,function(unix) OKCh(unix) end,function() OKCh() end)
  end
  fmw.update(loadList,fmwAddr,function(err)
    package.loaded[fmwpack] = nil
    if err ~= nil then
      print('??? firmware update error:',err)
      return
    end
    if file.exists('_xLOG') then
      fl.sendlog('_xLOG',fmwAddr..'log', function(err)
        if (err) then
          print('_xLOG was not sent')
        end
        if file.exists('_LOG') then
          fl.sendlog('_LOG',fmwAddr..'log', function(err)
            if (err) then
              print('_LOG was not sent')
            end
            syncTime()
          end)
        else
          syncTime()
        end
      end)
    else
      syncTime()
    end
  end)
end


-- ===============================================
loadUpdate()
