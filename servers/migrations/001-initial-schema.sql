-- Up
CREATE TABLE Devices (id TEXT  PRIMARY KEY, lastSeenAt DATETIME)

-- Down
DROP TABLE Devices
DROP TABLE Post;
