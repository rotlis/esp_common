g,r,b=16,16,16
build=0
mode=0
interval=0

mydns = require("mydns")

ws2812.init()
 i, buffer = 0, ws2812.newBuffer(13, 3);

buffer:fill(128, 128, 128);


function debounce (func)
    local last = 0
    local delay = 300000 -- 200ms * 1000 as tmr.now() has μs resolution

    return function (...)
        local now = tmr.now()
        local delta = now - last
        if delta < 0 then delta = delta + 2147483647 end; -- proposed because of delta rolling over, https://github.com/hackhitchin/esp8266-co-uk/issues/2
        if delta < delay then return end;

        last = now
        return func(...)
    end
end



function send_build_state(state)
    local tm = rtctime.get()
    if tm==0 then
        tm=tmr.now()
    end
    aname=EspId..".build."..state.."."..tm..".s.nbn.ioti.co"
    print(aname)
    net.dns.resolve(aname, function(sk, ip) print(ip) end)
end

function func_a()
    print("a")
    send_build_state(3)
end

function func_b()
    print("b")
    send_build_state(2)
end


pin_a,pin_b=5,6
gpio.mode(pin_a, gpio.INT, gpio.PULLUP )
gpio.mode(pin_b, gpio.INT, gpio.PULLUP )

gpio.trig(pin_a, "down", debounce(func_a))
gpio.trig(pin_b, "down", debounce(func_b))

local led_tmr = tmr.create()
led_tmr:register(1000, tmr.ALARM_AUTO, function()
        i=i+1
        if mode==0 then
            buffer:fade(2)
            buffer:set(i%buffer:size()+1, g, r, b)
        elseif mode==1 then
            if i%4==0 then
                buffer:fill(g,r,b)
            else
                buffer:fade(2)
            end    
        elseif mode==2 then   
            buffer:fill(g,r,b)
        end    
        ws2812.write(buffer)
end)
led_tmr:start()

local dns_comms_tmr=tmr.create()
local wd_tmr=tmr.create()
wd_tmr:register(60000, tmr.ALARM_SEMI, function()
        g,r,b=2,2,2
end)

function update_RGB_from_build()
    if build==0 then
        g,r,b=0,0,0 --unknown
    elseif build==1 then
        g,r,b=128,0,0 --success
    elseif build==2 then
        g,r,b=0,128,0 --fail
    elseif build==3 then
        g,r,b=0,0,128 --inprogress
    else
        g,r,b=0,0,0
    end
end

dns_comms_tmr:register(10000, tmr.ALARM_AUTO, function()
        mydns.mydns('build','mode','interval', function(cmdCode)
            wd_tmr:stop()
            wd_tmr:start()
            if cmdCode == 1 then 
                update_RGB_from_build()
            elseif cmdCode == 100 then
                require("loader").loadUpdate(UPDATE_URL)
            else
                print("Unknown command "..cmdCode)    
            end    

            -- TODO for debug only
            if mode==10 then
                dns_comms_tmr:stop()
                require("loader").loadUpdate(UPDATE_URL)
            end
        end)
end)
dns_comms_tmr:start()
