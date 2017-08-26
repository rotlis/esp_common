
mqttClient.setCallback(function(client, topic, message)
    print("MY HANDLER: MQTT topic:" .. topic .. ", message:" .. message)
end)
print("client start")
print("MQTT_BROKER_IP:"..MQTT_BROKER_IP)
