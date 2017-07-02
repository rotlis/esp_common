#!/usr/bin/env bash

nodemcu-tool fsinfo

nodemcu-tool upload bbl.lua
nodemcu-tool upload mqtt_client.lua
nodemcu-tool upload fileUtils.lua
nodemcu-tool upload init.lua
nodemcu-tool upload pattern_scroll.lua
nodemcu-tool upload pattern_steady.lua
nodemcu-tool upload patterns.lua
nodemcu-tool upload strip.lua
nodemcu-tool upload upgrader.lua

nodemcu-tool fsinfo

