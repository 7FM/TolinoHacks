#!/bin/sh

echo "Trying to boot the latest recovery image"

# TWRP for Page 2: https://github.com/Ryogo-Z/tolino_ntx_6sl_twrp/releases
rm -f twrp.img
wget https://github.com/Ryogo-Z/tolino_ntx_6sl_twrp/releases/latest/download/twrp.img > /dev/null 2>&1

# Test booting it first
echo "Please put your Tolino Page2 into fastboot mode!"
fastboot boot twrp.img

read -p "If TWRP booted successfully: Press Enter to continue" < /dev/tty

echo "Flashing the latest recovery image"

fastboot flash recovery twrp.img
rm twrp.img
