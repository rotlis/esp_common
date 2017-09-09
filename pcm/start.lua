stream = require("play_network")
stream.init(1)


gpio.mode(2, gpio.OUTPUT, gpio.PULLUP )
gpio.write(2, gpio.LOW)

mqttClient.setCallback(function(client, topic, message)
    tmr.alarm(0, 100, tmr.ALARM_SINGLE, function()
        gpio.write(2, gpio.HIGH)
        stream.play(pcm.RATE_16K, "192.168.2.32", "1880", "/audio.u8",
            function()
                gpio.write(2, gpio.LOW)
            end)
        end)
end)
