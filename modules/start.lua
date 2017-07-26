
mqttClient.setCallback(function(client, topic, message)
    print("MY HANDLER: MQTT topic:" .. topic .. ", message:" .. message)
end)
print("client start")
print("MQTT_BROKER_IP:"..MQTT_BROKER_IP)


tmr.alarm(2,5000, 1, function()
    LOGGER.log("time:"..tmr.now())
end)
