wifi.sleeptype(wifi.NONE_SLEEP)
wifi.setphymode(wifi.PHYMODE_B)
wifi.setmode(wifi.STATION)

wifi.sta.connect()

EspId = string.gsub(wifi.sta.getmac(), ':', '');
FileToExecute="start.lua"
l = file.list();
for k,v in pairs(l) do
    if k == FileToExecute then
        print("*** You've got 3 sec to stop timer 0 (e.g. tmr.stop(0))***")
        tmr.alarm(0, 3000, 0, function()
            print("Executing ".. FileToExecute)
            dofile(FileToExecute)
        end)
    end
end

