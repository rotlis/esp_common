dSLP = 60
aNTP = "pool.ntp.org"

loadList = LoadMode.."_list"
fmwTool = "fmw.lua"
fmwAddr = "http://172.20.10.5:3125/"
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

function checkInit(flist)
  local lst,ff,found = file.list(),0,nil
  for k,v in pairs(lst) do
    found = nil
    for _,fname in pairs(flist) do
      if k == fname then
        found = 1
        break
      end
    end
    if found == nil then
      if string.sub(k,1,1) ~= '_' then
        print("delete file: "..k)
        file.remove(k)
      end
    else
      ff = ff + 1
      print("loaded file: "..k..", size: "..v)
    end
  end
  if ff ~= table.getn(flist) then
    print('??? not the all files loaded...',ff,table.getn(flist))
    deepSl()
    return
  end
  print(ff..' files loaded. synchronizing time...')
  sntp.sync(aNTP,function(unix) OKCh(unix) end,function() OKCh() end)
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

function loadInit()
  local fl = require("fl")
  local url = fmwAddr..fmwTool.."?tagId="..EspId.."&reqType=load"
  fl.download(fmwTool,url,function(err)
    if err ~= nil then
      print('error: can not load the update tool')
      return deepSl()
    end
    local pti,ptj = string.find(fmwTool,'%.')
    local fmwpack = string.sub(fmwTool, 1, pti-1)
    local fmw = require(fmwpack)
    fmw.update(loadList,fmwAddr,function(err,flist)
      package.loaded[fmwpack] = nil
      if err ~= nil then
        print('??? firmware loading error:',err)
        return deepSl()
      end
      checkInit(flist)
    end)
  end)
end

-- ===============================================
wf = require("wf")

wf.connect(function(err)
  if err ~= nil then
    print(err)
    return deepSl()
  end
  if LoadMode == 'init' then
    loadInit()
  else
    loadUpdate()
  end
end)
