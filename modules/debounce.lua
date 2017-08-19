-- inspired by https://github.com/hackhitchin/esp8266-co-uk/blob/master/tutorials/introduction-to-gpio-api.md
-- and http://www.esp8266.com/viewtopic.php?f=24&t=4833&start=5#p29127
local pin = 7    --> GPIO2

function debounce (func)
    local last = 0
    local delay = 50000 -- 50ms * 1000 as tmr.now() has μs resolution

    return function (...)
        local now = tmr.now()
        local delta = now - last
        if delta < 0 then delta = delta + 2147483647 end; -- proposed because of delta rolling over, https://github.com/hackhitchin/esp8266-co-uk/issues/2
        if delta < delay then return end;

        last = now
        return func(...)
    end
end

function onChange ()
    print('The pin value has changed to '..gpio.read(pin))
end

gpio.mode(pin, gpio.INT, gpio.PULLUP) -- see https://github.com/hackhitchin/esp8266-co-uk/pull/1
gpio.trig(pin, 'both', debounce(onChange))
