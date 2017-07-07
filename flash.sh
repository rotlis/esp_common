#! /usr/bin/env bash

RED='\033[0;31m'
BRED='\033[1;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
BGREEN='\033[1;32m'
NC='\033[0m' # No Color

BIN_FOLDER='/Users/robertsayfullin/apps/esptool/esptool-master/'
toggleName=$1

devOps=$(ls /dev/tty* | grep -i 'usb')
binOps=$(ls $BIN_FOLDER | grep '.bin')


if [[ -z "$devOps" ]]; then
    echo "No usb tty devices connected"
    exit
fi

echo "ok"

select device in $devOps; do
    break
done;

select binary in $binOps; do
    break
done;

echo $device
echo $binary


python $BIN_FOLDER/esptool.py -p $device write_flash --flash_mode dio -fs 32m 0x00000 $BIN_FOLDER/$binary

#python esptool.py -p /dev/tty.SLAB_USBtoUART write_flash  --flash_mode dio -fs 32m 0x00000 _nunchuck_ws.bin

#python esptool.py -p /dev/cu.wchusbserial1420 write_flash  --flash_mode dio -fs 32m 0x00000 _budha_globe_uart.bin

#   python esptool.py -p /dev/tty.wchusbserial1410 write_flash  --flash_mode dio -fs 32m \
#    0x00000 _bbl_mqtt-2017-03-28-10-32-31-integer.bin \
#    0x3fc000 esp_init_data_default.bin
