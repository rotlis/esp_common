function containsKey(table, value)
    for k,v in pairs(table) do
        if k == value then
            return true
        end
    end
    return false
end

function containsValue(table, value)
    for k,v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function M.dec_hex(IN)
  local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
  if IN==0 then return "0" end
  while IN>0 do
    I=I+1
    IN,D=math.floor(IN/B),(IN%B)+1
    OUT=string.sub(K,D,D)..OUT
  end
  return OUT
end

function M.sigCode(lv)
  local rc = nil
  if lv > 99 then lv = 99 end
  if lv < 38 then lv = 38 end
  if lv < 48 then
	rc = string.char(lv+10)
  elseif lv < 74 then
    rc = string.char(lv+17)
  else
	rc = string.char(lv+23)
  end
  return rc
end

function M.batCode(bt)
  local bc,st = nil,nil
  if bt > 100 then bt = 100 end
  if bt < 0 then bt = 0 end
  if bt < 10 then
	bc = string.char(bt+48)
  elseif bt < 22 then
    bc = string.char(bt+55)
  else
	bt = math.floor(bt/2)*2
	if bt < 50 then
	  st = (bt-22)/2
      bc = string.char(bt+55-st)
    else
	  st = (bt-50)/2
	  bc = string.char(bt+47-st)
    end
  end
  return bc
end

function b64Code(str)
  local b64 = encoder.toBase64(str)
  b64 = string.gsub(b64,'+','-')
  b64 = string.gsub(b64,'/','_')
  return b64
end

--  unixHex = utl.dec_hex(ts)
--  unixHex = string.rep('0',8-unixHex:len())..unixHex
--

function encode(str)
     local bd = getHeader(ts)..ctnr
  local bc = math.floor(string.len(bd)/2)

  local dt = string.sub(bd,1,bc)..'.'..string.sub(bd,bc+1)..'.'..sADDR
  local sk = net.createConnection(net.UDP, 0)
--  utl.printLog('data to send: '..dt)
  print('data to send: '..dt)

end
