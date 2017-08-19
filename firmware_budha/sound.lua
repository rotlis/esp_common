local M={}

local volume=0
local selectDevice= '7E 03 35 01 EF'

local sleep= '7E 03 35 03 EF'
local wakeup='7E 03 35 02 EF'
local reset= '7E 03 35 05 EF'

-- volume is in range 0-30
local volumeUp = '7E 02 05 EF'
local volumeDown='7E 02 06 EF'
local setVolume = '7E 03 31 0F EF' --Set the volume to 15 (0x0F is 15)

local cyclePlay='7E 03 33 00 EF' --All songs cycle play mode
local stopPlay= '7E 02 0E EF'

local nextSong= '7E 02 03 EF'
local prevSong= '7E 02 04 EF'

local fastForward= '7E 02 0A EF'
local rewind= '7E 02 0B EF'

local volume_tmr = tmr.create()
local play_timeout_tmr = tmr.create()

local function getVolumeCmd(vol)
    return '7E 03 31 '..string.format('%02x',vol)..' EF'
end

local function exec(cmd)
    print(encoder.fromHex(string.gsub(cmd, ' ', ''))
end

function M.init()
    uart.setup(0, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
    exec(reset)
end

function M.volumeUp()
    volume = math.min(volume+1, 30)
    exec(getVolumeCmd(volume))
end

function M.volumeDown()
    volume = math.max(volume-1, 1)
    exec(getVolumeCmd(volume))
end

function fadeOut()
    volume_tmr:register(2000, tmr.ALARM_AUTO, function()
        if (volume==1) then
            volume_tmr:stop()
        else
            M.volumeDown()
        end
    end)
end

function fadeIn()
    volume_tmr:register(2000, tmr.ALARM_AUTO, function()
        if (volume==30) then
            volume_tmr:stop()
        else
            M.volumeUp()
        end
    end)
end

function M.startRelax()
    volume_tmr:stop()
    exec(wakeup)
    exec(reset)
    volume=10
    exec(getVolumeCmd(volume))
    exec(cyclePlay)

    play_timeout_tmr:register(PLAY_TIMEOUT, tmr.ALARM_SINGLE, fadeOut)
    play_timeout_tmr:start()
end

function M.stop()
    volume_tmr:stop()
    play_timeout_tmr:stop()
    exec(stopPlay)
    exec(sleep)
end

function M.startAlarm()
    volume_tmr:stop()
    exec(wakeup)
    exec(reset)
    volume=1
    exec(getVolumeCmd(volume))
    exec(cyclePlay)

    fadeIn()
end


return M
