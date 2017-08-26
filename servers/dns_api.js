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

var nsDomain = '.iotdns.ddns.net';
var nsDomainSet = '.set.iotdns.ddns.net';

var defaultOptions = {
    host: 'localhost',
    port: 3000,
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }
};

var restPostArgs = {
    data: {},
    headers: {
        "Content-Type": "application/json"
    }
};

function parseDnsGetRequest(name) {
    name = name.substring(0, name.length - nsDomain.length);
    var lexems = name.split("\.");
    return {
        mac: lexems[0],
        time: lexems[1],
        bat: lexems[2],
        varName1: lexems[3],
        varName2: lexems[4],
        varName3: lexems[5]
    };
};

function parseDnsSetRequest(name) {
    name = name.substring(0, name.length - nsDomainSet.length);
    var lexems = name.split("\.");
    return {
        mac: lexems[0],
        varName: lexems[1],
        varValue: lexems[2]
    };
};

function getTimeResponseWithPrefix(prefix){
    var now = new Date();
    return prefix + '.' + now.getHours() + '.' + now.getMinutes() + '.' + now.getSeconds();
}

//function getValueByNameFromAttrs(varName, restResponse) {
//    var attrStored = restResponse.find(at => at.name === varName);
//    return attrStored ? attrStored.value : 0;
//}

function getValueByNameFromAttrs(varName, restResponse) {
    return restResponse[varName] || 0;
}

function getIpResponse(requestObject, restResponse) {
    var timeShift = Math.round(parseInt(requestObject.time) - Date.now() / 1000);
//    console.log("timeShift:" + timeShift);

    return '1.' + getValueByNameFromAttrs(requestObject.varName1, restResponse) +
        '.' + getValueByNameFromAttrs(requestObject.varName2, restResponse) +
        '.' + getValueByNameFromAttrs(requestObject.varName3, restResponse);
}

dnsd.createServer(function (req, res) {
    if (req == null || req.question==null || req.question.size<1){
        console.log("rubbish");
        return;
    }
    var name = req.question[0].name;
    var ipResponse=getTimeResponseWithPrefix('254');
//    console.log(name);
    if (name.indexOf(nsDomain) > 0) {
        if (name.indexOf(nsDomainSet) > 0) {
            var requestObject = parseDnsSetRequest(name);
            //            /attr/:deviceId/:name/:value
            rest.post('http://localhost:3000/attr/' + requestObject.mac + '/' + requestObject.varName + '/' + requestObject.varValue,
                restPostArgs,
                function (restResponse) {
                    ipResponse=getTimeResponseWithPrefix('253');
                    console.log(name + " => " + ipResponse);
                    res.end(ipResponse);
                });

        } else {
            var requestObject = parseDnsGetRequest(name);

            rest.get('http://localhost:3000/attrs/' + requestObject.mac, function (restResponse) {
                ipResponse=getIpResponse(requestObject, restResponse);
                console.log(name + " => " + ipResponse);
                res.end(ipResponse);
            });
        }
    } else {
        console.log(name + " => " + ipResponse);
        res.end(ipResponse);
    }

}).listen(53, "")
console.log('Server running at 127.0.0.1:53')
