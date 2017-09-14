local M = {}

local i, z, h = 0, 0, 0
local buffer = ws2812.newBuffer(16, 3)
local light_timer = tmr.create()

buffer:fill(0, 0, 0, 0)

function hsvToRgb(h)
    local r, g, b
    local i = h/60;
    local t = h % 60;
    local p = 0;
    local q = 60-t;
    local v= 60;

    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v

    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end

    return r, g, b
end


function M.init()
    ws2812.init()
    buffer:fill(0, 0, 0)
    ws2812.write(buffer)
end

--function M.startMystery()
--    print("START mystery")
--
--    light_timer:stop()
--    local color = colors[math.random(12)]
--
--    light_timer:register( 40, tmr.ALARM_AUTO, function()
--        z = z + 5
--        --
--        buffer1:fill(0, 0, 0, 0);
--        buffer2:fill(0, 0, 0, 0);
--
--        for fd = 1, 4 do
--            buffer1:shift(1, ws2812.SHIFT_CIRCULAR)
--            buffer2:shift(-1, ws2812.SHIFT_CIRCULAR)
--            buffer1:fade(3)
--            buffer2:fade(3)
--            buffer1:set(i % 16 + 1, color)
--            buffer2:set(i % 16 + 1, color)
--        end
--        -- loads buffer with a crossfade between buffer1 and buffer2
--
--        buffer:mix(255, buffer1, 255, buffer2)
--
--        if z % 250 == 0 then
--            z = 0
--            i = i + 1
--            prebuffer:replace(buffer)
--            if i % 4 == 0 then
--                color = colors[math.random(12)]
--            end
--        else
--            buffer:mix(256 - z, prebuffer, z, buffer)
--            ws2812.write(buffer)
--        end
--    end)
--    light_timer:start()
--end

function M.startRainbow()
    light_timer:stop()

    light_timer:register( 200, tmr.ALARM_AUTO, function()
        h=(h+1)%360
        buffer:fill(hsvToRgb(h))
        ws2812.write(buffer)
    end)
    light_timer:start()
end

function M.startWhite()
    light_timer:stop()
    buffer:fill(128, 128, 128)
    ws2812.write(buffer)
end

function M.stop()
    light_timer:stop()
    buffer:fill(0, 0, 0, 0);
    ws2812.write(buffer)
end

return M


