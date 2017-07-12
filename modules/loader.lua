local M = {};

dSLP = 60

loadList = "update_list"
fmwTool = "fmw.lua"

fmwMod = nil
fmwVer = nil

function M.deepSl()
  print("deepSl")
  rtctime.dsleep(dSLP*1000000)
end

function M.OKCh(unix)
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
    rtctime.set(unix, 0)
    LOGGER.log('time is syncronized and saved...')
  end
  LOGGER.log('firmware is updated, restarting...')
  node.restart()
--  rtctime.dsleep(0)
end

function M.loadUpdate(fmwAddrUrl)
  local fl = require("fl")
  local pti,ptj = string.find(fmwTool,'%.')
  local fmwpack = string.sub(fmwTool, 1, pti-1)
  local fmw = require(fmwpack)
  local function syncTime()
    sntp.sync(aNTP,function(unix) M.OKCh(unix) end,function() M.OKCh() end)
  end
  fmw.update(loadList,fmwAddrUrl,function(err)
    package.loaded[fmwpack] = nil
    if err ~= nil then
      LOGGER.log("??? firmware update error:'"..err.."'")
      return
    end
    LOGGER.log("Updated. Syncing time..")
    syncTime()
  end)
end


-- ===============================================

return M
