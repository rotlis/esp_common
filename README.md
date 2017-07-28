


$EspId/status
{\"mac\":\""..EspId.."\", \"status\":\"online\"}
{\"mac\":\""..EspId.."\", \"status\":\"offline\"}


$EspId/cmd

$EspId/sys
{"cmd":"update", "url":"http://url/}

http-server -p 8081

mosquitto_pub -h 192.168.2.32 -p 1883 -q 0 -t  '5ccf7f193542/cmd' -m 'eksel moksel 12345'

mosquitto_pub -h 192.168.2.32 -p 1883 -q 0 -t  '5ccf7f193542/sys' -m '{"cmd":"update","url":"http://192.168.1.105:8080/"}'
 
mosquitto_pub -h 192.168.2.32 -p 1883 -q 0 -t  '5ccf7f193542/sys' -m '{"cmd":"restart"}'
 
 
 1970
 2017
 
32 bits back
2 bits - command default(color+time), restart, change interval

2 bits - color b,r,g,b
2^28 = 8.5 years
2^24 = 6 months time shift


Comm scenarios
1. simplest case
esp -> mac, time, voltage
esp <- color_cmd, refresh_interval, color

2. time shift
esp -> mac, time, voltage
esp <- shift_cmd, timeshift
esp -> mac, time, voltage
esp <- color_cmd, refresh_interval, color

