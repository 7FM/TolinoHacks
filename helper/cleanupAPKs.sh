#!/bin/sh

# Commands taken from: https://www.mobileread.com/forums/showpost.php?p=3951061&postcount=17
echo "Removing unnecessary APKs"

# Make the system partition writable
adb shell mount -o remount,rw /system
# Delete the System Crash Reporter application package (APK)
adb shell rm -f /system/app/systemcrashreporter.apk
# Make the system partition read-only again
adb shell mount -o remount,ro /system
