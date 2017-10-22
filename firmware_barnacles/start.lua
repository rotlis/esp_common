-- main entry point
if (adc.force_init_mode(adc.INIT_ADC)) then
    node.restart()
end


dofile('menu_struct.lua')
menu=require('menu')

menu.setstruct(menu_struct)
menu.show()

-- -----------------------------
-- init pins
gpio.mode(mosfet, gpio.OUTPUT, gpio.PULLDOWN)
gpio.mode(polarA, gpio.OUTPUT, gpio.PULLDOWN)
gpio.mode(polarB, gpio.OUTPUT, gpio.PULLDOWN)

gpio.write(mosfet, gpio.LOW)
gpio.write(polarA, gpio.LOW)
gpio.write(polarB, gpio.LOW)

--spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 8)

-- -----------------------------
vol = false
tick = 0

polarityState = 0
batteryVoltage = adc.read(0) -- initial read to prepopulate the 3/4 filter
powerSwitchCounter = 0

-- 1 - normal battery, 0 - low battery
batteryState = 0

-- -----------------------------
-- functions 

function polarityFlip()
    if (polarityState == 0) then
        gpio.write(polarA, gpio.HIGH)
    else
        gpio.write(polarB, gpio.HIGH)
    end
    polarityState=1-polarityState
    tmr.alarm(2, 50, 0, function() gpio.write(polarA, gpio.LOW); gpio.write(polarB, gpio.LOW); end)
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


function doEverySecond()
    tick = tick + 1
    log('Tick:' .. tick)
    measureBatteryVoltage()

    -- Save voltage reading in memory every 5 minutes
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


function measureBatteryVoltage()
    batteryVoltage = (adc.read(0) + 3 * batteryVoltage) / 4
--    log('Battery voltage measured at ' .. batteryVoltage)

    if batteryState == 1 and batteryVoltage < lowVoltageThreshold then
        batteryState = 0
--        log('Measure voltage: detected battery is LOW. Operations STOPPED.')
--        persist("low battery - powering off")
--        flipPowerSwitch()
    end

    if batteryState == 0 and batteryVoltage > highVoltageThreshold then
        batteryState = 1
--        log('Measure voltage: detected battery is OK. RESUMING operations.')
--        persist("powering on")
--        flipPowerSwitch()
    end
end

function log(m)
   print(m) 
end    

-- -----------------------------


--mountSDCard()

--initLogFile()

measureBatteryVoltage()

polarityFlip()

--initWifi()

tmr.alarm(1, 1000, 1, doEverySecond)


