--wifi.sleeptype(wifi.NONE_SLEEP)
--wifi.setphymode(wifi.PHYMODE_G)
--wifi.setmode(wifi.STATION)
--
--wifi.sta.connect()
--



print("*** You've got 2 sec to stop timer 0 (e.g. tmr.stop(0))***")

tmr.alarm(0,2000,0, function()
    if file.exists("config.lua") then
        dofile("config.lua")
    end

    if file.exists("start.lua") then
        print("Executing start.lua")
        dofile("start.lua")
    else
        print("No start.lua found")
    end

end)
