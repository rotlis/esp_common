
-- VAR
vol = false
tick = 0

polarityState = 0
batteryVoltage = adc.read(0) -- initial read to prepopulate the 3/4 filter
powerSwitchCounter = 0

-- 1 - normal battery, 0 - low battery
batteryState = 0


gpio.mode(mosfet, gpio.OUTPUT, gpio.PULLDOWN)
gpio.mode(polarA, gpio.OUTPUT, gpio.PULLDOWN)
gpio.mode(polarB, gpio.OUTPUT, gpio.PULLDOWN)

gpio.write(mosfet, gpio.LOW)
gpio.write(polarA, gpio.LOW)
gpio.write(polarB, gpio.LOW)

spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 8)


-- FUNCTIONS


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
                else
                        print("404")
                        conn:send("404")
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

    if (tick % 10 == 0) then
        flipPowerSwitch()
    end

    -- Every hour reboot
    if (tick % 3600 == 0) then
        node.restart()
    end

    if batteryState == 0 then
        return
    end

    -- Every half an hour flip polarity
    if (tick % 1800 == 0) then
        polarityFlip()
    end
end


function log(msg)
    print(msg)
end


-- main entry point
if (adc.force_init_mode(adc.INIT_ADC)) then
    node.restart()
end

measureBatteryVoltage()

polarityFlip()

initWifi()

tmr.alarm(1, 1000, 1, doEverySecond)

