
--globals = require('globals')
--fmwMod,fmwVer,sTIME,dSINT,lMODE,wSSID,bSSID = globals.readfiles(EspId)

-- constants
--highVoltageThreshold = 860 -- 13.0v

lowVoltageThreshold = 815 -- 12.3v
highVoltageThreshold = 835 -- 12.6v

-- VAR
logFileName = 'data000.json'
vol = false
tick = 0

polarityState = 0
batteryVoltage = adc.read(0) -- initial read to prepopulate the 3/4 filter
powerSwitchCounter = 0
powerSwitchDivisor = 5 -- on when counter%divisor==0. Eg. 1=>100%, 2=>50%, 3=>33%, 4=>25%, 5=>20%

-- 1 - normal battery, 0 - low battery
batteryState = 0
-- RTC backed variables



mosfet = 2
--polarA = 7
--polarB = 6
polarA = 0
polarB = 1
spiSlaveSelect = 12

gpio.mode(mosfet, gpio.OUTPUT, gpio.PULLDOWN)
gpio.mode(polarA, gpio.OUTPUT, gpio.PULLDOWN)
gpio.mode(polarB, gpio.OUTPUT, gpio.PULLDOWN)

gpio.write(mosfet, gpio.LOW)
gpio.write(polarA, gpio.LOW)
gpio.write(polarB, gpio.LOW)

spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 8)


-- FUNCTIONS

function mountSDCard()
    log('Mounting SD card...')
    vol = file.mount("/SD0", spiSlaveSelect) -- 2nd parameter is optional for non-standard SS/CS pin
    if not vol then
        log("Retrying mounting SD card...")
        vol = file.mount("/SD0", spiSlaveSelect)
        if not vol then
            log('Failed to mount SD card.')
            return
        end
    end
    log('SD card mounted successfully.')
end


function persist(optionalMessage)
    if not vol then
        log('SD not mounted. Pesrsit skipped')
        return
    end
    log('Persisting data...')

    if file.open("/SD0/" .. logFileName, "a+") then
        log('File on SD card opened successfully.')
        local jsonEncodedData = cjson.encode({
            heap = node.heap(),
            tick = tick,
            batteryState = batteryState,
            polarityState = polarityState,
            batteryVoltage = batteryVoltage,
            powerSwitchCounter = powerSwitchCounter,
            message = optionalMessage
        })
        if (file.writeline(jsonEncodedData)) then
            log('Data written to file on SD card.')
        else
            log('ERROR writing to file on SD card.')
        end

        file.close()
    else
        log('Failed to open file on SD card.')
    end
end


function flipPowerSwitch()
    if (batteryState == 1) then
        powerSwitchCounter = powerSwitchCounter + 1
        if (powerSwitchCounter % powerSwitchDivisor == 0) then
            gpio.write(mosfet, gpio.HIGH)
        else
            gpio.write(mosfet, gpio.LOW)
        end
    else
        gpio.write(mosfet, gpio.LOW)
    end
end


function polarityFlip()
    if (polarityState == 0) then
        gpio.write(polarA, gpio.HIGH)
        polarityState = 1
    else
        gpio.write(polarB, gpio.HIGH)
        polarityState = 0
    end
    tmr.alarm(2, 50, 0, function() gpio.write(polarA, gpio.LOW); gpio.write(polarB, gpio.LOW); end)
end


function measureBatteryVoltage()
    batteryVoltage = (adc.read(0) + 3 * batteryVoltage) / 4
    log('Battery voltage measured at ' .. batteryVoltage)

    if batteryState == 1 and batteryVoltage < lowVoltageThreshold then
        batteryState = 0
        log('Measure voltage: detected battery is LOW. Operations STOPPED.')
        persist("low battery - powering off")
        flipPowerSwitch()
    end

    if batteryState == 0 and batteryVoltage > highVoltageThreshold then
        batteryState = 1
        log('Measure voltage: detected battery is OK. RESUMING operations.')
        persist("powering on")
        flipPowerSwitch()
    end
end


function initWifi()
    apcfg = {}
    apcfg.ssid = "ESP-Rept"
    apcfg.pwd = "ekselMoksel"

    wifi.setphymode(wifi.PHYMODE_B)
    wifi.setmode(wifi.SOFTAP)
    wifi.ap.config(apcfg)

    -- a simple http server
    srv = net.createServer(net.TCP)
    srv:listen(80, function(conn)
        conn:on("receive", function(conn, payload)

            local _, _, method, path, vars = string.find(payload, "([A-Z]+) (.+)?(.+) HTTP");
            if (method == nil) then
                _, _, method, path = string.find(payload, "([A-Z]+) (.+) HTTP");
            end


            if method == "GET" then
                if "/info" == path then

                    conn:send(cjson.encode({
                        heap = node.heap(),
                        tick = tick,
                        batteryState = batteryState,
                        voltageReadingTick = voltageReadingTick,
                        polarityFlipTick = polarityFlipTick,
                        polarityState = polarityState,
                        batteryVoltage = batteryVoltage,
                        powerSwitchCounter = powerSwitchCounter,
                        voltageReadings = voltageReadings
                    }))
                    conn:on("sent", function() conn:close() end)
                elseif "/list" == path then
                    file.chdir("/SD0")
                    local l = file.list();
                    local response = {"<html><body><hr/>"}
                    for k, v in pairs(l) do
                        response[#response + 1] = "<a href='"..k.."'>"..k .. " ("..v..")</a><br/>\n"
                    end
                    response[#response+1]="<hr/></body></html>"
                    local function senda(sk)
                        if #response > 0 then
                            sk:send(table.remove(response, 1))
                        else
                            sk:close()
                            response = nil
                        end
                    end
                    -- triggers the send() function again once the first chunk of data was sent
                    conn:on("sent", senda)
                    senda(conn)
                else
                    local fileName =  "/SD0/"..string.gsub(path, "/", "")
                    print("fileName:" .. fileName)
                    if file.exists(fileName) then
                        conn:send("<html><body><a href='/list'>Back to list</a><br/><hr/><pre>")
                        if file.open(fileName, "r") then
                            local function sendb(sk)
                                local line = file.readline()
                                print(line)
                                if line~=nil then
                                    sk:send(line)
                                else
                                    sk:send("</pre><hr/></body></html>")
                                    file.close()
                                    sk:close()
                                end
                            end
                            conn:on("sent", sendb)
                            sendb(conn)
                        else
                            print("Can't read")
                            sk:send("can't read")
                            sk:close()
                        end
                    else
                        print("404")
                        conn:send("404")
                    end
                end
            end
        end)
    end)
end

function stopWifi()
    tmr.stop(4) -- if we are still waiting for ip
    wifi.sta.disconnect()
    wifi.setmode(wifi.NULLMODE)
end


function doEverySecond()
    tick = tick + 1
    log('Tick:' .. tick)

    measureBatteryVoltage()

    -- Save voltage reading in memory every 5 minutes
    if (tick % 10 == 0) then
        --    if (tick % 10 == 0) then
--        persist('')
        flipPowerSwitch()
    end

    -- Every hour reboot
    if (tick % 3600 == 0) then
        --    if (tick % 100 == 0) then
        node.restart()
    end

    if batteryState == 0 then
        return
    end

    -- Every half an hour flip polarity
    if (tick % 1800 == 0) then
        --    if (tick % 50 == 0) then
        polarityFlip()
        --        initiateSendOverWifi()
    end
end


function log(msg)
    print(msg)
end

function initLogFile()
    if vol then
        file.chdir("/SD0")
        local highestLogNum = -1
        local l = file.list();
        for k, v in pairs(l) do
            numSt = string.match(k, 'data([0-9]*).json')
            if numSt ~= nil then
                num = tonumber(numSt)
                if (num > highestLogNum) then
                    highestLogNum = num
                end
            end
        end

        print(string.format("Highest log num so far is %d", highestLogNum))
        logFileName = string.format('data%03d.json', highestLogNum + 1)
    end
end

-- main entry point
if (adc.force_init_mode(adc.INIT_ADC)) then
    node.restart()
end

mountSDCard()

initLogFile()

measureBatteryVoltage()

polarityFlip()

initWifi()

tmr.alarm(1, 1000, 1, doEverySecond)

