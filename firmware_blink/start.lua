print("blink 5 started")
tmr.alarm(2,1000, 1, function()
    mqttClient.log("time:"..tmr.now())
end)
