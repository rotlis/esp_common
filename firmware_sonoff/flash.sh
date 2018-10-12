#! /usr/bin/env bash

esptool.py -b 921600 -p /dev/cu.usbserial-A700eZt9 write_flash  --flash_mode dout -fs detect 0x00000 _sonoff.bin 0xfc000 esp_init_data_default.bin
