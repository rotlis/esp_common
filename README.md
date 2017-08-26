


$EspId/status
{\"mac\":\""..EspId.."\", \"status\":\"online\"}
{\"mac\":\""..EspId.."\", \"status\":\"offline\"}


$EspId/cmd

$EspId/sys
{"cmd":"update", "url":"http://url/}

http-server -p 8081

mosquitto_pub -h 192.168.2.32 -p 1883 -q 0 -t  '5ccf7f193542/cmd' -m 'eksel moksel 12345'

mosquitto_pub -h 192.168.2.32 -p 1883 -q 0 -t  '5ccf7f193542/sys' -m '{"cmd":"update","url":"http://192.168.1.105:8080/"}'
 
mosquitto_pub -h 192.168.2.32 -p 1883 -q 1 -t  '5ccf7f193542/sys' -m '{"cmd":"restart"}'
mosquitto_pub -h 192.168.2.32 -p 1883 -q 1 -t  '5ccf7f1a52e0/sys' -m '{"cmd":"restart"}'
mosquitto_pub -h 192.168.2.32 -p 1883 -q 1 -t  '60019400966a/sys' -m '{"cmd":"restart"}'
mosquitto_pub -h 192.168.2.32 -p 1883 -q 1 -t  '5ccf7fc25763/sys' -m '{"cmd":"restart"}'
mosquitto_pub -h 192.168.2.32 -p 1883 -q 1 -t  '5ccf7fc25565/sys' -m '{"cmd":"restart"}'
 
 
 curl  http://localhost:3000/devices 
curl -X POST http://192.168.2.32:3000/attr/5ccf7fc25565/build/2

nslookup 5ccf7f193542.0.3.build.mode.interval.iotdns.ddns.net 192.168.2.32
nslookup 5ccf7fc25763.build.1.set.iotdns.ddns.net 203.219.46.28


curl http://203.219.46.28/db_api/attrs/5ccf7f193542
curl http://203.219.46.28/db_api/attrs/5ccf7f1a52e0
curl http://203.219.46.28/db_api/attrs/60019400966a
curl http://203.219.46.28/db_api/attrs/5ccf7fc25763
curl http://203.219.46.28/db_api/attrs/5ccf7fc25565



 
 1970
 2017
 
32 bits back

2 bits - command default(color+time), restart, change interval
2 bits - color b,r,g,b

2^28 = 8.5 years
2^24 = 6 months time shift


Interval 
0 - 15 sec * val => 15s - 1h (-unnecessary high precission )
0


Comm scenarios
1. simplest case
esp -> mac, time, voltage
esp <- color_cmd, refresh_interval, color

2. time shift
esp -> mac, time, voltage
esp <- shift_cmd, timeshift
esp -> mac, time, voltage
esp <- color_cmd, refresh_interval, color

