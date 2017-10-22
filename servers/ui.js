var fs = require('fs');

var express = require("express");
var bodyParser = require("body-parser");
var app = express();

var RestClient = require('node-rest-client').Client;
var rest = new RestClient();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: true
}));

// ------------------------------ devices -----------------------------------


app.get("/ui", function (req, res) {
        res.end();
})

app.get("/devices", function(req,res){
    rest.get('http://localhost:3000/attrs', function (restResponse) {
        console.log(restResponse);
        res.send(restResponse);
        res.end();
    });
})

// ------------------------------ plumbing -----------------------------------

var server = app.listen(80, function () {
    console.log("Listening on port %s...", server.address().port);
});
