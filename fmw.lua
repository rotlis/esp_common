local moduleName = ...
local M = {}
_G[moduleName] = M

function M.update(ufile,uaddr,cbU)
  local reqType = (LoadMode == 'init') and 'load' or 'update'
  local url = uaddr..ufile.."?tagId="..EspId.."&reqType="..reqType
  file.remove(ufile)
  fl.download(ufile,url,function(err)
    if nil ~= err or nil == file.open(ufile) then
      cbU('can not get list to load...')
      return
    end
    local ii,flist,line = 0,{},nil
    local function loadFile()
      if ii <= 0 then
        local okurl = uaddr.."okay".."?tagId="..EspId.."&reqType="..reqType
        fl.download("okay",okurl,function(err)
          cbU(nil,flist)
          end)
        return
      end
      if LoadMode == 'update' and string.sub(flist[ii],1,1) == '#' then
        file.remove(string.sub(flist[ii],2))
        ii = ii - 1
        loadFile()
      else
        local url = uaddr..flist[ii].."?tagId="..EspId.."&reqType="..reqType
        fl.download(flist[ii],url,function(err)
          if nil ~= err then
            return cbU('some files are not updated')
          end
          ii = ii - 1
          loadFile()
        end)
      end
    end
    while true do
      line = file.readline()
      if line == nil or string.sub(line, 1, -2) == "" then break end
      line = string.sub(line, 1, -2)
      if ii == 0 then
        fmwMod = line
      elseif ii == 1 then
        fmwVer = line
      else
        flist[ii-1] = line
      end
      ii = ii + 1
    end
    ii = ii - 2
    file.close()
    if ii >= 0 then
      loadFile()
    else
      cbU('bad format of the load list...')
    end
  end)
end

return M
