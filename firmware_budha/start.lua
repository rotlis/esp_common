light = require("light")
sound = require("sound")

mqttClient.setCallback(function(client, topic, message)
    print("MY HANDLER: MQTT topic:" .. topic .. ", message:" .. message)
end)


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


--        startMystery()
--        startRainbow()
--    tmr.alarm(1, tonumber(duration) * 1000, 0, stop)
--            if topic == 'MP3/cmd' then
--                local hexstr= string.gsub(data, ' ', '');
--                binary = encoder.fromHex(hexstr)
--                uart.write(0, binary)
--                --                print(binary)
--            end





