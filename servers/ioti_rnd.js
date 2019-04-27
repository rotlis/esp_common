var AES = require("crypto-js/aes");
var SHA256 = require("crypto-js/sha256");
var CryptoJS = require("crypto-js");

let pass_bytes = [];

let b;

for (i = 0; i < 16; i++) {
    b=Math.round(Math.random()*255);
    pass_bytes.push(b);
    console.log(b);
}
// pass_bytes.push(0);

console.log(pass_bytes);
let pass=Buffer.from(pass_bytes).toString();
let pass_based=Buffer.from(pass_bytes).toString('base64');
console.log("pass: ", pass_based);


// var key = CryptoJS.enc.Hex.parse('000102030405060708090a0b0c0d0e0f');
var iv1 = CryptoJS.enc.Hex.parse('101112131415161718191a1b1c1d1e1f');
var iv2 = CryptoJS.enc.Hex.parse('000102030405060708090a0b0c0d0e0f');
// let iv1='1234567890123456';
// let iv2='nbvcdfghjhgfddfg';

// var encrypted = CryptoJS.AES.encrypt("Message", key, { iv: iv });


var ciphertext = CryptoJS.AES.encrypt("chronos-prod.1.user.jeevan", pass, {iv: iv1});
console.log("encrypted: ", ciphertext.toString());

// Buffer.from('hello world', 'utf8').toString('hex');
var hexed = Buffer.from(ciphertext.toString(), 'ascii').toString('hex');
var base = Buffer.from(ciphertext.toString(), 'ascii').toString('base64');

console.log("hexed: ", hexed.toString());
console.log("based: ", base.toString());

// Decrypt
var bytes = CryptoJS.AES.decrypt(ciphertext.toString(), pass, {iv: iv1});
var plaintext = bytes.toString(CryptoJS.enc.Utf8);

console.log("decrypted: ",plaintext);


// LUA

// crypto = require('crypto');
// cipher = crypto.encrypt("AES-CBC", "0123456789abcdef", wifi.sta.getmac(), '0000000000000000')


// DNS
// A label may contain zero to 63 characters
// The full domain name may not exceed the length of 253 characters in its textual representation.

// Although no technical limitation exists to use any character in domain name labels which are representable by an octet,
// hostnames use a preferred format and character set. The characters allowed in labels are a subset of the ASCII character set,
// consisting of characters a through z, A through Z, digits 0 through 9, and hyphen. This rule is known as the LDH rule (letters, digits, hyphen). Domain names are interpreted in case-independent manner.[25] Labels may not start or end with a hyphen.[26] An additional rule requires that top-level domain names should not be all-numeric.


// NTP
// On systems where the representation of Unix time is as a signed 32-bit number
/*
sec  60
min  60  3600
hour 24  86400

day  31  2678400
month 12 32140800
year  10 321408000
==============


 */
