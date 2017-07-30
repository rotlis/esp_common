var fs = require('fs');
var dgram = require('dgram');

var express = require("express");
var bodyParser = require("body-parser");
//var logger = require('morgan');
var app = express();

var sqlite3 = require('sqlite3');
var db = new sqlite3.Database('./database.sqlite');

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: true
}));

// ------------------------------ devices -----------------------------------

app.post("/device/:id", function (req, res) {
    console.log(req.params.id);
    db.run("INSERT OR IGNORE INTO Devices (id, lastSeenAt) VALUES ($id, datetime('now'))", {
            $id: req.params.id
        });
    db.run("UPDATE Devices set lastSeenAt=datetime('now') WHERE id=$id", {
            $id: req.params.id
        });
    res.end();
})

app.delete("/device/:id", function (req, res) {
    db.run("DELETE FROM Devices WHERE id=$id", {
        $id: req.params.id
    });
    res.end();
})

app.get("/device/:id", function (req, res) {
    db.all("SELECT * from Devices where id=$id", {
        $id: req.params.id
    }, function (err, rows) {
        console.log(rows);
        res.send(rows);
        res.end();
    });
})

app.get("/devices", function (req, res) {
    db.all("SELECT * from Devices", function (err, rows) {
        console.log(rows);
        res.send(rows);
        res.end();
    });
})

// ------------------------------ attrs -----------------------------------

app.post("/attr/:deviceId/:name/:value", function (req, res) {
    db.run("DELETE FROM Attrs WHERE deviceId=$deviceId AND name=$name", {
        $deviceId: req.params.deviceId,
        $name: req.params.name
    });
    db.run("INSERT INTO Attrs (deviceId, name, value) VALUES ($deviceId,$name,$value)", {
        $deviceId: req.params.deviceId,
        $name: req.params.name,
        $value: req.params.value
    });
    res.end();
})

app.delete("/attr/:deviceId/:name", function (req, res) {
    db.run("DELETE FROM Attrs WHERE deviceId=$id and name=$name", {
        $id: req.params.deviceId,
        $name: req.params.name
    });
    res.end();
})

app.get("/attrs/:deviceId", function (req, res) {
    db.all("SELECT * from Attrs where deviceId=$id", {
        $id: req.params.deviceId
    }, function (err, rows) {
        console.log(rows);
        res.send(rows);
        res.end();
    });
})

// ------------------------------ log -----------------------------------

app.post("/log/:deviceId/:name/:value/:createdAt?", function (req, res) {
    console.log(req.params.createdAt || 'now');
    if (req.params.createdAt) {
        db.run("INSERT INTO Log (deviceId, name, value, createdAt) VALUES ($deviceId,$name,$value, datetime($createdAt, 'unixepoch'))", {
            $deviceId: req.params.deviceId,
            $name: req.params.name,
            $value: req.params.value,
            $createdAt: req.params.createdAt
        });
    }else{
        db.run("INSERT INTO Log (deviceId, name, value, createdAt) VALUES ($deviceId,$name,$value, datetime('now'))", {
            $deviceId: req.params.deviceId,
            $name: req.params.name,
            $value: req.params.value
        });
    }
    res.end();
})

app.get("/log/:deviceId/:name?", function (req, res) {
    if (req.params.name!=null) {
        db.all("SELECT * from Log where deviceId=$deviceId and name=$name", {
                $deviceId: req.params.deviceId,
                $name: req.params.name
            },
            function (err, rows) {
                console.log(rows);
                res.send(rows);
                res.end();
            })
    } else {
        db.all("SELECT * from Log where deviceId=$deviceId ", {
                $deviceId: req.params.deviceId
            }, function (err, rows) {
                console.log(rows);
                res.send(rows);
                res.end();
            }
        )
    }
})

// ------------------------------ plumbing -----------------------------------

var server = app.listen(3000, function () {
    console.log("Listening on port %s...", server.address().port);
});
