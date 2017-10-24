var fs = require('fs');
var pmx = require('pmx');

var express = require("express");
var bodyParser = require("body-parser");
var app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: true
}));


var devices=new Map();
var devices={};
// ------------------------------ actions -----------------------------------
pmx.action('clear', function(reply) {
    devices={};
    reply({ result : 'ok' });
});

pmx.action('all devices', function(reply) {
    reply({ devices : devices });
});

pmx.action('set mode for all', function(param, reply){
    Object.keys(devices).forEach(function(mac) {
        devices[mac]['mode']=param;
    });
    reply({ result : 'ok' });
});

pmx.action('set attr', function(param, reply){
    param=JSON.parse(param);
    devices[param.mac][param.key]=param.value;
    reply({ result : 'ok' });
});
// ------------------------------ devices -----------------------------------

app.post("/device/:id", function (req, res) {
    var mac=req.params.id;
    console.log("post "+mac);
    if (devices[mac]){
        devices[mac].lastSeenAt=new Date();
    }else{
        devices[mac]={lastSeenAt:new Date(), build:"0"};
    }
    res.send({});
    res.end();
})

app.delete("/device/:id", function (req, res) {
    var mac=req.params.id;
    delete devices[mac];
    res.send({});
    res.end();
})

app.get("/device/:id", function (req, res) {
    var mac=req.params.id;
    if (devices[mac]){
        res.send(devices[mac]);
        res.end();
    }else{
        res.send({});
        res.end();
    }
})

app.get("/devices", function (req, res) {
    console.log(devices);
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.send(devices);
    res.end();
})

// ------------------------------ attrs -----------------------------------

app.post("/attr/:deviceId/:name/:value", function (req, res) {
    var mac=req.params.deviceId;
    if (!devices[mac]){
        devices[mac]={};
    }
    devices[mac][req.params.name]=req.params.value;
    res.send({});
    res.end();
})

app.delete("/attr/:deviceId/:name", function (req, res) {
    var mac=req.params.deviceId;
    if(devices[mac]){
        delete devices[mac][req.params.name];
    }
    res.send({});
    res.end();
})

app.get("/attrs/:deviceId?", function (req, res) {
    var mac=req.params.deviceId;
    if (mac){
        if (devices[mac]){
            devices[mac].lastSeenAt=new Date();
        }else{
            devices[mac]={lastSeenAt:new Date(), build:"0"};
        }
        res.send(devices[mac]);
        res.end();
    }else{
        res.send(devices);
        res.end();
    }
})

// ------------------------------ plumbing -----------------------------------

var server = app.listen(3000, function () {
    console.log("Listening on port %s...", server.address().port);
});
