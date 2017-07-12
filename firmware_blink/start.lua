print("blink 5 started")
tmr.alarm(2,1000, 1, function()
   LOGGER.log("5 time:"..tmr.now())
end)
