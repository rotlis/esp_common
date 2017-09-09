local M={}

local PLAY_TIMEOUT=30*60*1000

local minVolume=1
local maxVolume=20
local startVolume=12
local startAlarmVolume=3
local volume=12

local fadeInStepDelay=15
local fadeOutStepDelay=5

local selectDevice= '7E033501EF'

local sleep= '7E033503EF'
local wakeup='7E033502EF'
local reset= '7E033505EF'

local setVolume = '7E03310FEF' --Set the volume to 15 (0x0F is 15)

local allSongsCyclePlay='7E 03 33 00 EF' --All songs cycle play mode
local singleCyclePlay='7E 03 33 01 EF' --single cycle play mode

local startPlay= '7E0201EF'
local stopPlay= '7E020EEF'

local nextSong= '7E 02 03 EF'
local prevSong= '7E 02 04 EF'

local volume_tmr = tmr.create()
local play_timeout_tmr = tmr.create()

local isPlaying=false

local function intToHex(i)
    return string.format('%02x',i)
end

local function getVolumeCmd(vol)
    return '7E 03 31 '..intToHex(vol)..' EF'
end

local function getRandomNumbersFromSequense(howMany,maxNumber)
    local sequence={}
    local songs={}
    for i=1,maxNumber do table.insert(sequence,i) end
    for i=1,howMany do
         table.insert(songs, table.remove(sequence,math.random(1,#sequence)))
    end
    return songs
end

local function getPlayListCmd(folder, songsCount)
    local totalSongsCount = 20
    local songs=getRandomNumbersFromSequense(songsCount,totalSongsCount)
    local cmd='7E'..intToHex(2+songsCount*2)..'45'
    for i=1,#songs do
        local songN=songs[i]
        if songN==10 then songN=21 end
        if songN==13 then songN=22 end
       cmd = cmd..intToHex(folder)..intToHex(songN)
    end
    return cmd..'EF'
end

function M.exec(cmd)
--    print(cmd)
    tmr.delay(100000)
    print(encoder.fromHex(string.gsub(cmd, ' ', '')))
end

function M.init()
    uart.setup(0, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, 0)
    M.exec(reset)
    M.exec(selectDevice)
    M.exec(sleep)
    isPlaying=false
end

function M.volumeUp()
    volume = math.min(volume+1, 30)
    print("volumeup:"..volume)
    M.exec(getVolumeCmd(volume))
end

function M.volumeDown()
    volume = math.max(volume-1, 1)
    print("volumedown:"..volume)
    M.exec(getVolumeCmd(volume))
end

function fadeOut()
    print("fadeout start")
    volume_tmr:register(fadeOutStepDelay*1000, tmr.ALARM_AUTO, function()
        if (volume<=minVolume) then
            volume_tmr:stop()
            M.exec(stopPlay)
            isPlaying=false
            light.stop()
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
    M.exec(wakeup)
    volume_tmr:stop()
    volume=startVolume
    M.exec(getPlayListCmd(1,7))
    M.exec(getVolumeCmd(volume))
    isPlaying=true
    play_timeout_tmr:register(PLAY_TIMEOUT, tmr.ALARM_SINGLE, fadeOut)
    play_timeout_tmr:start()
end

function M.startAlarm()
    M.exec(wakeup)
    volume_tmr:stop()
    volume=startAlarmVolume
    M.exec(getPlayListCmd(2,7))
    M.exec(getVolumeCmd(volume))
    isPlaying=true
    fadeIn()
end

function M.stop()
    volume_tmr:stop()
    play_timeout_tmr:stop()
    M.exec(stopPlay)
    M.exec(sleep)
    isPlaying=false
end

function M.toggleRelax()
    if isPlaying then
        M.stop()
        light.stop()
    else
        M.startRelax()
        light.startRainbow()
    end
end

return M
