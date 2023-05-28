#!/bin/sh

cp "$1" EPubProd.apk
adb shell mount -o remount,rw /system
adb push EPubProd.apk /system/app/
adb shell chown root.root /system/app/EPubProd.apk
adb shell chmod 644 /system/app/EPubProd.apk
adb shell chcon u:object_r:system_file:s0 /system/app/EPubProd.apk
adb shell mount -o remount,ro /system
adb reboot
