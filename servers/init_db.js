var fs = require('fs')
var Promise = require('bluebird');;//.Promise;
var sqlite3 = require('sqlite3');

var db = new sqlite3.Database('./database.sqlite');
// db.exec('CREATE TABLE Devices (id TEXT  PRIMARY KEY, lastSeenAt DATETIME)')
// db.exec('CREATE TABLE Attrs (id INTEGER PRIMARY KEY ASC, deviceId TEXT, name TEXT, value TEXT)')
// db.exec('CREATE TABLE Log (id INTEGER PRIMARY KEY ASC, deviceId TEXT, name TEXT, value TEXT, createdAt DATETIME)')
