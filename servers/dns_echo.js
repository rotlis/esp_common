var fs = require('fs');
var dgram = require('dgram');

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
//----------------------------------------------------------------------------------------------
var comma = "";
//----------------------------------------------------------------------------------------------
var dnsd = require('dnsd');
dnsd.createServer(function(req, res) {
    console.log(req);
    if(req.question[0].name.indexOf('rotlis.ddns.net')>0){
    	fs.appendFile('dns_requests.txt', comma+"\n"+req.question[0].name, 'utf8', function(){});
    	comma = ",";
    }
    var now = new Date();
    var resp = '254'+'.'+now.getHours()+'.'+now.getMinutes()+'.'+now.getSeconds();
    console.log(resp);
    res.end(resp);
}).listen(53, "")
console.log('Server running at 127.0.0.1:53')
