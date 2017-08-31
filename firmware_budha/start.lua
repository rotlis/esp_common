light = require("light")
sound = require("sound")

light.init()
sound.init()

mqttClient.setCallback(function(client, topic, message)
    print("MY HANDLER: MQTT topic:" .. topic .. ", message:" .. message)
    if message=='alarm' then
        sound.startAlarm()
        light.startWhite()
    else if message=='relax' then
        sound.startRelax()
        light.startRainbow()
    else if message=='stop' then
        sound.stop()
        light.stop()
    else
end)

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

local pin_a,pin_b,pin_c=7,6,5
local pin_d,pin_e,pin_f=1,2,3
gpio.mode(pin_a, gpio.INT, gpio.PULLUP )
gpio.mode(pin_b, gpio.INT, gpio.PULLUP )
gpio.mode(pin_c, gpio.INT, gpio.PULLUP )

gpio.mode(pin_d, gpio.INT, gpio.PULLUP )
gpio.mode(pin_e, gpio.INT, gpio.PULLUP )
gpio.mode(pin_f, gpio.INT, gpio.PULLUP )


gpio.trig(pin_a, "down", debounce(light.startWhite))
gpio.trig(pin_b, "down", debounce(light.stop))
gpio.trig(pin_c, "down", debounce(light.startMystery))

gpio.trig(pin_d, "down", debounce(sound.volumeUp))
gpio.trig(pin_e, "down", debounce(sound.toggleRelax))
gpio.trig(pin_f, "down", debounce(sound.volumeDown))

