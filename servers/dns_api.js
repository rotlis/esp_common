var fs = require('fs');
var dgram = require('dgram');
var http = require('http');
//var rest = require('rest');

var RestClient = require('node-rest-client').Client;
var rest = new RestClient();


var extend = require('util')._extend;

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
var dnsd = require('dnsd');

var nsDomain = '.iot.rotlis.ddns.net';
var defaultOptions = {
    host: 'localhost',
    port: 3000,
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }
};

function parseDnsRequest(name) {
    name = name.substring(0, name.length - nsDomain.length);
    var lexems = name.split("\.");
    return {
        mac: lexems[0],
        time: lexems[1],
        bat: lexems[2]
    };
};

function getIpResponse(requestObject, restResponse) {

    if (restResponse.length > 0) {
        //esp <- color_cmd, refresh_interval, color

    }
}

dnsd.createServer(function (req, res) {
    var name = req.question[0].name;
    if (name.indexOf(nsDomain) > 0) {
        var requestObject = parseDnsRequest(name);
        var args = {
            data: {},
            headers: {
                "Content-Type": "application/json"
            }
        };
        rest.post('http://localhost:3000/device/' + requestObject.mac, args, function (restResponse) {
            //ignore response from keepalive call
        });

        rest.get('http://localhost:3000/attrs/' + requestObject.mac, function (restResponse) {
            console.log(restResponse);
            console.log(restResponse[0].id);
            res.end(getIpResponse(requestObject, restResponse));
        });

    } else {
        var now = new Date();
        var resp = '254' + '.' + now.getHours() + '.' + now.getMinutes() + '.' + now.getSeconds();
        console.log(resp);
        res.end(resp);
    }
}).listen(53, "")
console.log('Server running at 127.0.0.1:53')
