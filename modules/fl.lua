local moduleName = ...
local M = {}
_G[moduleName] = M

function M.download(filename,url,cbL)
  local hdr,flopn,flerr,isTrunc = '',false,false,false
  local function fsave(res)
    if isTrunc then
      file.write(res)
      return
    end
    hdr = hdr..res
    local i,j = string.find(hdr,'\r\n\r\n')
    if i == nil or j == nil then
      return
    end
    local pfx = string.sub(hdr,j+1,-1)
    file.write(pfx)
    hdr = ''
    isTrunc = true
    return
  end
  local ip,port,path = string.gmatch(url,'http://([0-9.]+):?([0-9]*)(/.*)')()
  local sk = net.createConnection(net.TCP,false)
  sk:connect(port,ip)
  sk:on('connection', function(sk)
    print('...connection:',filename)
    sk:send("GET "..path.." HTTP/1.0\r\n"..
      "Host: "..ip.."\r\n"..
      "Connection: close\r\n"..
      "Accept-Charset: utf-8\r\n"..
      "Accept-Encoding: \r\n"..
      "User-Agent: esp\r\n"..
      "Accept: */*\r\n\r\n")
  end)
  sk:on('receive',function(sck,res)
    if string.find(string.sub(res,1,50),'500 Internal Server Error') == nil then
      if not flerr then
        if not flopn then
          file.remove(filename)
          file.open(filename,'w')
          flopn = true
        end
        fsave(res)
      end
    else
      flerr = true
    end
  end)
  sk:on('disconnection',function(sck,res)
    local function reset()
      hdr = ''
      isTrunc = false
      tmr.stop(0)
      if flopn then
        file.flush()
        file.close()
      end
      if (not flopn) or flerr then
        cbL(true)
      else
        cbL(nil)
      end
    end
    tmr.alarm(0,1000,1,reset)
  end)
end
return M
