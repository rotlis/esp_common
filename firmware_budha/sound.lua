local M={}

PLAY_TIMEOUT=3*60*1000

volume=1
selectDevice= '7E 03 35 01 EF'

sleep= '7E 03 35 03 EF'
wakeup='7E 03 35 02 EF'
reset= '7E 03 35 05 EF'

-- volume is in range 0-30
volumeUp = '7E 02 05 EF'
volumeDown='7E 02 06 EF'
setVolume = '7E 03 31 0F EF' --Set the volume to 15 (0x0F is 15)

allSongsCyclePlay='7E 03 33 00 EF' --All songs cycle play mode
singleCyclePlay='7E 03 33 01 EF' --single cycle play mode

startPlay= '7E 02 01 EF'
stopPlay= '7E 02 0E EF'

nextSong= '7E 02 03 EF'
prevSong= '7E 02 04 EF'

fastForward= '7E 02 0A EF'
rewind= '7E 02 0B EF'

volume_tmr = tmr.create()
play_timeout_tmr = tmr.create()


function intToHex(i)
    return string.format('%02x',i)
end

function getVolumeCmd()
    return '7E 03 31 '..intToHex(volume)..' EF'
end


function M.exec(cmd)
    print(cmd)
    tmr.delay(50000)
    print(encoder.fromHex(string.gsub(cmd, ' ', '')))
    tmr.delay(500000)

end


function M.init()
    uart.setup(0, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, 0)
    M.exec(reset)
    M.exec(selectDevice)
end

function M.volumeUp()
    volume = math.min(volume+1, 30)
    print("volumeup:"..volume)
    M.exec(getVolumeCmd())
end

function M.volumeDown()
    volume = math.max(volume-1, 1)
    print("volumedown:"..volume)
    M.exec(getVolumeCmd())
end

function fadeOut()
    print("fadeout start")
    volume_tmr:register(2000, tmr.ALARM_AUTO, function()
        if (volume==1) then
            volume_tmr:stop()
            print("fadeout stop")
        else
            M.volumeDown()
        end
    end)
    volume_tmr:start()
end

function fadeIn()
    print("fadein start")
    volume_tmr:register(1000, tmr.ALARM_AUTO, function()
        if (volume==30) then
            volume_tmr:stop()
            print("fadein stop")
        else
            M.volumeUp()
        end
    end)
    volume_tmr:start()
end

function M.startRelax()
    M.exec(reset)
    M.exec(selectDevice)
    volume_tmr:stop()
    volume=15
--    M.exec(wakeup)
--    M.exec(stopPlay)
--    M.exec(allSongsCyclePlay)
    M.exec(getVolumeCmd())
    M.exec('7E '..intToHex(16)..' 45 01 01 01 02 01 03 01 04 01 05 01 06 01 07 EF')
--    tmr.alarm(0, 1000, tmr.ALARM_SINGLE, function() M.exec(startPlay) end)
    M.exec(startPlay)

    play_timeout_tmr:register(PLAY_TIMEOUT, tmr.ALARM_SINGLE, fadeOut)
    play_timeout_tmr:start()
end

function M.startAlarm()
    M.exec(wakeup)
    M.exec(reset)
    M.exec(selectDevice)
    volume_tmr:stop()
    volume=5
    M.exec(getVolumeCmd())

--    M.exec(wakeup)
    M.exec(singleCyclePlay)
    M.exec(stopPlay)
    M.exec('7E '..intToHex(16)..' 45 02 01 02 02 02 03 02 04 02 05 02 06 02 07 EF')
--    tmr.alarm(0, 1000, tmr.ALARM_SINGLE, function() M.exec(startPlay) end)
    M.exec(startPlay)
    fadeIn()
end

function M.stop()
    volume_tmr:stop()
    play_timeout_tmr:stop()
    M.exec(stopPlay)
--    M.exec(sleep)
end

function M.test1()
    M.exec('7E 04 31 1E 01 EF')
end


return M
