local M = {};

SEC = 1000
AUTORECONNECT = 1
INSECURE = 0
MQTT_PORT = 1883

QOS_2 = 2
RETAIN = 1

local mqttClientObj
local brokerIp
--local currentlyMonitoredTopic

function M.init(mqttBrokerIp, onMessageCallback)
    brokerIp = mqttBrokerIp
    mqttClientObj = mqtt.Client(EspId, 120)
    mqttClientObj:lwt(EspId.."/status", "{\"mac\":\""..EspId.."\", \"status\":\"offline\"}", QOS_2, RETAIN)
    mqttClientObj:on("connect", function(client) print ("connected to MQTT Broker") end)
    mqttClientObj:on("offline", function(client)
        print("MQTT Went offline. Reconnecting...")
        M.reconnectMqtt()
    end)
    mqttClientObj:on("message", onMessageCallback)
    mqttClientObj:on("message", function(client, topic, message)
        if(topic==EspId.."/sys") then
            print("Got system message '"..message.."' on topic "..topic)

        else
            onMessageCallback(client, topic, message)
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
    print("Waiting for Wifi")
    if wifi.sta.status() == 5 and wifi.sta.getip() ~= nil then
        print("Wifi connected")
        mqttClientObj:connect(brokerIp, MQTT_PORT, INSECURE, AUTORECONNECT, function(client)
            print("MQTT Connected to " .. brokerIp)

            mqttClientObj:subscribe({[EspId.."/cmd"]=2,[EspId.."/sys"]=2}, function(client)
                mqttClientObj:publish(EspId.."/status", "{\"mac\":\""..EspId.."\", \"status\":\"online\"}", QOS_2, RETAIN)
            end)
        end,
            function(client, reason)
                print("MQTT failed reason: " .. reason)
                M.reconnectMqtt()
            end)
    else
        tmr.alarm(0, 1000, 0, function()
            M.reconnectMqtt()
        end)
    end
end

return M

