


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
 
