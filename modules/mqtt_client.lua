local M = {};

SEC = 1000
NO_AUTORECONNECT = 0
INSECURE = 0
MQTT_PORT = 1883

QOS_0 = 0
QOS_2 = 2
NO_RETAIN = 0
RETAIN = 1

local connected=false

local mqttClientObj
local brokerIp
local mqtt_timer = tmr.create()
--local currentlyMonitoredTopic
local onMessageCallback=function(c,t,m)
    print("callback placeholder. topic:"..t..",msg:"..m)
end

function M.setCallback(cb)
    onMessageCallback=cb
end

function M.init(mqttBrokerIp)
    brokerIp = mqttBrokerIp
    mqttClientObj = mqtt.Client(EspId, 120)
    mqttClientObj:lwt(EspId.."/status", "{\"mac\":\""..EspId.."\", \"status\":\"offline\"}", QOS_2, RETAIN)
    mqttClientObj:on("connect", function(client)
            print ("connected to MQTT Broker")
    end)
    mqttClientObj:on("offline", function(client)
        connected = false
        print("MQTT Went offline. Reconnecting...")
        M.reconnectMqtt()
    end)

    mqttClientObj:on("message", function(client, topic, message)
        if(topic==EspId.."/sys") then
            print("Got system message '"..message.."' on topic "..topic)
            local msgObj = cjson.decode(message)
            if(msgObj['cmd']=="update") then
                print("command:"..msgObj['cmd']..", url:"..msgObj['url'])
                require("loader").loadUpdate(msgObj['url'])
            elseif(msgObj['cmd']=="restart") then
                node.restart()
            else
                LOGGER.log("unknown command")
            end
        else
            onMessageCallback(client, topic, message)
        end
    end)
    LOGGER.addAppender(function(m)
        if connected then
            mqttClientObj:publish(EspId.."/log", EspId..":"..m, QOS_0, NO_RETAIN)
        end
    end)
    M.reconnectMqtt()
end

function M.send(topic, message)
    mqttClientObj:publish(topic, message, QOS_2, RETAIN)
end

function M.subscribe(topic)
--    if currentlyMonitoredTopic~=nil then
--        local topicToUnsubscribe = currentlyMonitoredTopic
--        mqttClientObj:unsubscribe(topicToUnsubscribe, function(conn)
--            print("unsubscribe successfuly from "..topicToUnsubscribe)
--        end)
--    end

    mqttClientObj:subscribe(topic, QOS_2, function(client)
--        currentlyMonitoredTopic =topic
        print("Mqtt Subscribed to topic "..topic)
    end)
end


function M.reconnectMqtt()
    --print("Waiting for Wifi")
    if wifi.sta.status() == wifi.STA_GOTIP and wifi.sta.getip() ~= nil then
        print("Wifi connected")
        mqttClientObj:connect(brokerIp, MQTT_PORT, INSECURE, NO_AUTORECONNECT, function(client)
            connected = true
            print("MQTT Connected to " .. brokerIp)

            mqttClientObj:subscribe({[EspId.."/cmd"]=2,[EspId.."/sys"]=2}, function(client)
                mqttClientObj:publish(EspId.."/status", "{\"mac\":\""..EspId.."\", \"status\":\"online\", \"firmware\":\""..FIRMWARE_NAME.."\", \"version\":\""..FIRMWARE_VERSION.."\"}", QOS_2, RETAIN)
            end)
        end,
            function(client, reason)
                connected = false
                print("MQTT failed reason: " .. reason)
                M.reconnectMqtt()
            end)
    else
        connected = false
        mqtt_timer:register(1000, tmr.ALARM_SINGLE, function()
            M.reconnectMqtt()
        end)
        mqtt_timer:start()
    end
end

return M

