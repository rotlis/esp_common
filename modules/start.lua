
mqttClient.setCallback(function(client, topic, message)
    print("MY HANDLER: MQTT topic:" .. topic .. ", message:" .. message)
end)
print("client start")
print("MQTT_BROKER_IP:"..MQTT_BROKER_IP)


tmr.alarm(2,1000, 1, function()
    mqttClient.log("time:"..tmr.now())
end)
