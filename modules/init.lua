wifi.sleeptype(wifi.NONE_SLEEP)
wifi.setphymode(wifi.PHYMODE_G)
wifi.setmode(wifi.STATION)

wifi.sta.connect()

EspId = string.gsub(wifi.sta.getmac(), ':', '')
print('EspId:'..EspId)
FIRMWARE_NAME="Unknown"
FIRMWARE_VERSION="NA"
if file.open(EspId) ~= nil then
    FIRMWARE_NAME = file.read()
    file.close()
end
if file.open("_VER") ~= nil then
    FIRMWARE_VERSION = file.read()
    file.close()
end


print("*** You've got 2 sec to stop timer 0 (e.g. tmr.stop(0))***")

tmr.alarm(0,2000,0, function()
    dofile("properties.lua")
    if file.exists("config.lua") then
       dofile("config.lua")
    end
--    require("wf").startScan()
    LOGGER = require("logger")

    if FT_MQTT then
        mqttClient = require("mqtt_client")
        mqttClient.init(MQTT_BROKER_IP)
    end

    if file.exists("start.lua") then
        print("Executing start.lua")
        dofile("start.lua")
    else
        print("No start.lua found")
    end

end)
