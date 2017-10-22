local M = {};

local lastPos=0
local stepSensitivity=4

function M.init(channel, pinA, pinB, pinPress, rotateCB, pressCB)
    rotary.setup(channel, pinA,pinB, pinPress)
    lastPos=rotary.getpos(0)
--    rotary.setup(0, 5,6, 7)

    rotary.on(0, rotary.TURN, function (type, pos, when)
      --print("Position=" .. pos .. " event type=" .. type .. " time=" .. when)
      local newPos =  pos
      local shift=0
      if newPos >= lastPos+stepSensitivity then
        shift=-1
        lastPos=newPos
      elseif newPos <= lastPos-stepSensitivity then
        shift=1
        lastPos=newPos
      end
      if shift~=0 then
        return rotateCB(shift)
      end
    end)

    rotary.on(0, rotary.PRESS, function(type, pos, when)
        return pressCB()
    end)
end


--rotary.on(0, rotary.ALL, function (type, pos, when)
--
--end)

--PRESS, LONGPRESS, RELEASE, TURN, CLICK or DBLCLICK

return M
