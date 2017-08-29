local M={}

PLAY_TIMEOUT=3*60*1000

minVolume=1
maxVolume=20
startVolume=12
startAlarmVolume=5
volume=12

fadeInStepDelay=10
fadeOutStepDelay=2

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

function getRandomNumbersFromSequense(howMany,maxNumber)
    local sequence={}
    local songs={}
    for i=1,maxNumber do table.insert(sequence,i) end
    for i=1,howMany do
         table.insert(songs, table.remove(sequence,math.random(1,#sequence)))
    end
    return songs
end

function getPlaylistCmd(folder, songsCount)
    local totalSongsCount = folder==1 and 20 or 30
    local songs=getRandomNumbersFromSequense(songsCount,totalSongsCount)
    --for i=1,#songs do print(songs[i]) end
    local cmd='79 '..intToHex(2+songsCount*2)
    for i=1,#songs do
       cmd = cmd..' '..intToHex(folder)..' '..intToHex(songs[i])
    end
    return cmd..' EF'
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
    volume_tmr:register(fadeOutStepDelay*1000, tmr.ALARM_AUTO, function()
        if (volume<=minVolume) then
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
    volume_tmr:register(fadeInStepDelay*1000, tmr.ALARM_AUTO, function()
        if (volume>=maxVolume) then
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
    volume=startVolume
--    M.exec(wakeup)
--    M.exec(stopPlay)
--    M.exec(allSongsCyclePlay)
    M.exec(getVolumeCmd())
    M.exec(getPlayListCmd(1,7))
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
    volume=startAlarmVolume
    M.exec(getVolumeCmd())

--    M.exec(wakeup)
    M.exec(singleCyclePlay)
    M.exec(stopPlay)
    M.exec(getPlayListCmd(2,7))
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
