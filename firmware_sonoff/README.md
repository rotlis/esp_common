


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

nslookup mymac.0.3.build.mode.interval.iotdns.ddns.net 127.0.0.1
nslookup mymac.build.1.set.iotdns.ddns.net 127.0.0.1

