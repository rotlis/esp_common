id = 0
sda = 1
scl = 2
alert_pin = 3

i2c.setup(id, sda, scl, i2c.SLOW)
ads1115.setup(ads1115.ADDR_GND)
a={}
a[0]=ads1115.SINGLE_0
a[1]=ads1115.SINGLE_1
a[2]=ads1115.SINGLE_2
a[3]=ads1115.SINGLE_3
tick=0

tmr.alarm(0,500,1, function()
    tick=tick+1
    ndx=tick%4
    ads1115.setting(ads1115.GAIN_4_096V,
        ads1115.DR_128SPS,
        a[ndx],
        ads1115.SINGLE_SHOT
    )



    ads1115.startread(function(volt, volt_dec, adc)
        print(ndx, volt, volt_dec, adc)
    end)
end)


