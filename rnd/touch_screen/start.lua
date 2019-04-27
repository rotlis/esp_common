spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8, 16, spi.FULLDUPLEX)


t_cs  = 2 -- d2 GPIO4
t_irq = 1 -- d1 GPIO5
xpt2046.init(t_cs,t_irq,320,240)
xpt2046.setCalibration(198, 1776, 1762, 273)

gpio.mode(t_irq, gpio.INT, gpio.PULLUP)
gpio.trig(t_irq, "down", function()
    print(xpt2046.getPosition())
    local x,y=xpt2046.getPosition()
    if x<65535 and y<65535 then
        print(x,y)  --xpt2046.isTouched())
        disp:drawFrame(x, y, 5, 5)
    end
end)


tft_cs  = 8 -- d8 gpio15
tft_dc  = 4 --d4 gpio2
res = 0 -- GPIO16, RES is optional YMMV
disp = ucg.ili9341_18x240x320_hw_spi(tft_cs, tft_dc, res)


--=============================

disp:begin(1)--UCG_FONT_MODE_TRANSPARENT)
disp:clearScreen()

disp:setColor(255, 0, 0)
disp:drawFrame(50, 30, 45, 20)
disp:drawGradientBox(0, 0, disp:getWidth(), disp:getHeight())

mx = disp:getWidth() / 2
x = 0
while x < mx do
    xx = ((x)*255)/mx
    disp:setColor(255, 255-xx/2, 255-xx)
    disp:drawPixel(x*2, 24)
    disp:drawVLine(x*2+7, 26, 13)
    x = x + 1
end
--disp:setFontMode(ucg.FONT_MODE_TRANSPARENT)

disp:setColor(255, 200, 170)
disp:setFont(ucg.font_helvB08_hr)
disp:setPrintPos(20,130)
disp:print("ABC abc 123")