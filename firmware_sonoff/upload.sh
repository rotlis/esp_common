#!/usr/bin/env bash

nodemcu-tool fsinfo

nodemcu-tool upload ../modules/init.lua
nodemcu-tool upload ../modules/wf.lua
nodemcu-tool upload ../modules/logger.lua
nodemcu-tool upload ../modules/mqtt_client.lua
nodemcu-tool upload ../modules/fl.lua
nodemcu-tool upload ../modules/fmw.lua
nodemcu-tool upload ../modules/loader.lua

nodemcu-tool upload properties.lua
nodemcu-tool upload start.lua

nodemcu-tool fsinfo

