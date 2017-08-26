
uart.on("data", "|",
  function(data)
    local aname=string.gsub(data, '|', '')
    print("receive from uart:", aname)
    net.dns.setdnsserver('203.219.46.28', 0)
    net.dns.setdnsserver('192.168.2.32', 1)
    net.dns.resolve(aname, function(sk, ip)
         if (ip == nil) then
             print("DNS fail!")
         else
             print(ip)
         end
    end)
end, 0)

