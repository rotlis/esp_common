local properties = require("properties")
local mqttClient = require("mqtt_client")

mqttClient.init(MQTT_BROKER_IP, function(client, topic, message)
    print("MQTT topic:" .. topic .. ", message:" .. message)
end)


print("client start")
print("MQTT_BROKER_IP:"..MQTT_BROKER_IP)
