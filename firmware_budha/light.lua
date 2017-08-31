local M = {}

local prebuffer = ws2812.newBuffer(16, 3)
local i, z = 0, 0
local buffer, buffer1, buffer2 = ws2812.newBuffer(16, 3), ws2812.newBuffer(16, 3), ws2812.newBuffer(16, 3)
local light_timer = tmr.create()

prebuffer:fill(0, 0, 0, 0)

local colors = {
    { 255, 0, 0 }, --red
    { 255, 128, 0 },
    { 255, 255, 0 }, --yellow
    { 128, 255, 0 },
    { 0, 255, 0 }, --green
    { 0, 255, 128 },
    { 0, 255, 255 }, --cyan
    { 0, 128, 255 },
    { 0, 0, 255 }, --blue
    { 128, 0, 255 },
    { 255, 0, 255 }, --magenta
    { 255, 0, 128 }
}

function M.init()
    ws2812.init()
    buffer:fill(0, 0, 0, 0)
    ws2812.write(buffer)
end

function M.startMystery()
    print("START mystery")

    light_timer:stop()
    local color = colors[math.random(12)]

    light_timer:register( 40, tmr.ALARM_AUTO, function()
        z = z + 5
        --
        buffer1:fill(0, 0, 0, 0);
        buffer2:fill(0, 0, 0, 0);

        for fd = 1, 4 do
            buffer1:shift(1, ws2812.SHIFT_CIRCULAR)
            buffer2:shift(-1, ws2812.SHIFT_CIRCULAR)
            buffer1:fade(3)
            buffer2:fade(3)
            buffer1:set(i % 16 + 1, color)
            buffer2:set(i % 16 + 1, color)
        end
        -- loads buffer with a crossfade between buffer1 and buffer2

        buffer:mix(255, buffer1, 255, buffer2)

        if z % 250 == 0 then
            z = 0
            i = i + 1
            prebuffer:replace(buffer)
            if i % 4 == 0 then
                color = colors[math.random(12)]
            end
        else
            buffer:mix(256 - z, prebuffer, z, buffer)
            ws2812.write(buffer)
        end
    end)
    light_timer:start()
end

function M.startRainbow()
    print("START rainbow")
    light_timer:stop()
    color = colors[i % 12 + 1]

    light_timer:register( 40, tmr.ALARM_AUTO, function()
        z = z + 5
        --
        buffer1:fill(0, 0, 0, 0);
        buffer2:fill(0, 0, 0, 0);

        for fd = 1, 4 do
            buffer1:shift(1, ws2812.SHIFT_CIRCULAR)
            buffer2:shift(-1, ws2812.SHIFT_CIRCULAR)
            buffer1:fade(3)
            buffer2:fade(3)
            buffer1:set(i % 16 + 1, color)
            buffer2:set(i % 16 + 1, color)
        end
        -- loads buffer with a crossfade between buffer1 and buffer2

        buffer:mix(255, buffer1, 255, buffer2)

        if z % 250 == 0 then
            z = 0
            i = i + 1
            prebuffer:replace(buffer)
            --            if i%4==0 then
            color = colors[i % 12 + 1]
            --            end
        else
            buffer:mix(256 - z, prebuffer, z, buffer)
            ws2812.write(buffer)
        end
    end)
    light_timer:start()
end

function M.startWhite()
    print("START white")
    light_timer:stop()
    buffer:fill(128, 128, 128, 0)
    ws2812.write(buffer)
end

function M.stop()
    print("STOP lights")
    light_timer:stop()
    buffer:fill(0, 0, 0, 0);
    ws2812.write(buffer)
end

return M


