
a,b=3,4 -- D3, D4

gpio.mode(a, gpio.INT, gpio.PULLUP )
gpio.mode(b, gpio.INT, gpio.PULLUP )


gpio.trig(a, "down", function()print("a")end)
gpio.trig(b, "down", function()print("b")end)


spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8, 1, spi.FULLDUPLEX)


cs  = 2
dc  = 1
res = 0 -- GPIO16, RES is optional YMMV
disp = ucg.ili9341_18x240x320_hw_spi(cs, dc, res)

disp:begin(1)  --UCG_FONT_MODE_TRANSPARENT)

function scan()

    function listap(t)
        disp:setFont(ucg.font_helvB12_hr)
        disp:clearScreen()
        if nil ~= next(t) then
            y = 20
            for bssid,v in pairs(t) do
                local ssid, rssi, authmodestr, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]*)")
                authmode=tonumber(authmodestr)
                if authmode==wifi.OPEN then
                    disp:setColor(0, 250, 0)
                elseif authmode==wifi.WPA_PSK then
                    disp:setColor(0, 250, 250)
                elseif authmode==wifi.WPA2_PSK then
                    disp:setColor(0, 0, 250)
                elseif authmode==wifi.WPA_WPA2_PSK then
                    disp:setColor(250, 0, 0)
                else
                    disp:setColor(250, 250, 250)
                end

                disp:setPrintPos(4, y)
                disp:print(ssid)
                disp:setPrintPos(200, y)
                disp:print(rssi .. " ".. authmode)
                y = y + 20
            end
        end
    end
    wifi.sta.getap(1, listap)
end

--scan()
disp:setFont(ucg.font_helvB18_hr)
disp:clearScreen()

disp:setColor(0, 250, 0)
disp:setPrintPos(10, 30)
disp:print(wifi.OPEN.." OPEN")

disp:setColor(0, 250, 250)
disp:setPrintPos(10, 60)
disp:print(wifi.WPA_PSK .. " WPA-PSK")

disp:setColor(0, 0, 250)
disp:setPrintPos(10, 90)
disp:print(wifi.WPA2_PSK .. " WPA2-PSK")

disp:setColor(250, 0, 0)
disp:setPrintPos(10, 120)
disp:print(wifi.WPA_WPA2_PSK .. " WPA_WPA2_PSK")




tmr.alarm(3,10000,1, scan)
