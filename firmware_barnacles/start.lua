-- main entry point
if (adc.force_init_mode(adc.INIT_ADC)) then
    node.restart()
end

dofile('menu_struct.lua')
menu = require('menu')

menu.setstruct(menu_struct)
menu_struct = nil

-- -----------------------------
-- init pins
gpio.mode(mosfet, gpio.OUTPUT, gpio.PULLUP)
gpio.mode(polarA, gpio.OUTPUT, gpio.PULLUP)
gpio.mode(polarB, gpio.OUTPUT, gpio.PULLUP)

gpio.write(mosfet, gpio.HIGH)
gpio.write(polarA, gpio.HIGH)
gpio.write(polarB, gpio.HIGH)

--spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 8)

function getBat()
    return (adc.read(0) * BATT_KOEF) / 100
end

function zapOn()
    zapState = 1
    gpio.write(mosfet, gpio.LOW)
end

function zapOff()
    zapState = 0
    gpio.write(mosfet, gpio.HIGH)
end

-- -----------------------------
tick = 0
zapState = 0

polarityState = 0
batteryVoltage = getBat() -- initial read to prepopulate the 3/4 filter
powerSwitchCounter = 0

-- 1 - normal battery, 0 - low battery
batteryState = 0

-- -----------------------------
-- functions 


function polarityFlip()
    if (polarityState == 0) then
        gpio.write(polarA, gpio.LOW)
    else
        gpio.write(polarB, gpio.LOW)
    end
    polarityState = 1 - polarityState
    tmr.alarm(3, 50, 0, function() gpio.write(polarA, gpio.HIGH); gpio.write(polarB, gpio.HIGH); end)
end


function flipPowerSwitch()
    if (batteryState == 1) then
        if (tick % 100 > duty_cycle and zapState == 1) then
            zapOff()
        end
        if (tick % 100 < duty_cycle and zapState == 0) then
            zapOn()
        end
    else
        zapOff()
    end
end


function doEverySecond()
    tick = tick + 1
    log(tick..":"..node.heap())
    measureBatteryVoltage()
    flipPowerSwitch()

    menu.show()

    if (tick % (5*60) == 0) then
        post()
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


function measureBatteryVoltage()
    batteryVoltage = (getBat() + 3 * batteryVoltage) / 4

    if batteryState == 1 and batteryVoltage < low_bat then
        batteryState = 0
        log('Measure voltage: detected battery is LOW. Operations STOPPED.')
        zapOff()
    end

    if batteryState == 0 and batteryVoltage > high_bat then
        batteryState = 1
        log('Measure voltage: detected battery is OK. RESUMING operations.')
    end
end

function getInfoLines()
    local lines = {}
    table.insert(lines, "B:" .. tostring(batteryState) .. ":" .. tostring(batteryVoltage) .. " mV")

    table.insert(lines, "Z:" .. tostring(zapState) .. ":" .. tostring(tick % 100) .. "|" .. tostring(duty_cycle) .. "%")

    if (tick / 4 % 2 == 0) then
        table.insert(lines, "Heap:" .. tostring(node.heap()))
    else
        if wifi.sta.status() == wifi.STA_GOTIP and wifi.sta.getip() ~= nil then
            if (tick  % 2 == 0) then
                table.insert(lines, "" .. wifi.sta.getconfig(true).ssid)
            else
                table.insert(lines, "" .. wifi.sta.getip())
            end
        else
            table.insert(lines, "Offline")
        end
    end
    return lines
end

function log(m)
    print(m)
end


function post()
    if wifi.sta.status() == wifi.STA_GOTIP and wifi.sta.getip() ~= nil then
        http.post("http://api.thingspeak.com/update?api_key=" .. THINGSPEAK_KEY ..
                "&field1=" .. tostring(batteryVoltage) ..
                "&field2=" .. tostring(batteryState) ..
                "&field3=" .. tostring(duty_cycle) ..
                "&field4=" .. tostring(node.heap()) ..
                "&field5=" .. tostring(tick) ..
                "&field6=" .. tostring(polarityState),
            {},
            "",
            function(code, data)
                if (code < 0) then
                    print("HTTP request failed")
                else
                    print(code, data)
                end
            end)
    end
end

-- -----------------------------

measureBatteryVoltage()

polarityFlip()

tmr.alarm(1, 1000, 1, doEverySecond)
--tmr.alarm(2, 1000, 1, menu.show)


