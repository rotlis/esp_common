
mqttClient.setCallback(function(client, topic, message)
    print("MY HANDLER: MQTT topic:" .. topic .. ", message:" .. message)
end)
print("client start")
print("MQTT_BROKER_IP:"..MQTT_BROKER_IP)

g,r,b=16,16,16
build=0
mode=0
interval=0

mydns = require("mydns")

ws2812.init()
 i, buffer = 0, ws2812.newBuffer(8, 3);

buffer:fill(0, 50, 0, 0);

local led_tmr = tmr.create()
led_tmr:register(1000, tmr.ALARM_AUTO, function()
        i=i+1
        buffer:fade(2)
        buffer:set(i%buffer:size()+1, g, r, b)
        ws2812.write(buffer)
end)
led_tmr:start()

function repaint()
--    buffer:fill(0, g, r, b);
--    ws2812.write(buffer)
end

local dns_comms_tmr=tmr.create()
local wd_tmr=tmr.create()
wd_tmr:register(60000, tmr.ALARM_SEMI, function()
        g,r,b=2,2,2
        repaint()
end)

dns_comms_tmr:register(12000, tmr.ALARM_AUTO, function()
        mydns.mydns('build','mode','interval', function()
            wd_tmr:stop()
            wd_tmr:start()

            -- success, fail, inprogress
            if build==0 then
                g,r,b=0,0,0 --unknown
            elseif build==1 then
                g,r,b=128,0,0 --success
            elseif build==2 then
                g,r,b=0,128,0 --fail
            elseif build==3 then
                g,r,b=0,0,128
            else
                g,r,b=0,0,0
            end
            repaint()
        end)
end)
dns_comms_tmr:start()
