#!/bin/sh

echo "Patching the EPubProd APK"

# NOTE: the name may not be altered
patchedAPK="EPubProd.apk"

# Obtain the EPubProd.apk
adb pull /system/app/EPubProd.apk
hash=`sha256 EPubProd.apk`
cp EPubProd.apk "EPubProd_${hash}.apk"
echo "Backing up unpatched EPubProd.apk as EPubProd_${hash}.apk"

# Apply patches/changes
TODO


echo "Uploading patched EPubProd APK"

# Commands are taken from: https://www.mobileread.com/forums/showpost.php?p=3951131&postcount=18

adb shell mount -o remount,rw /system
adb push "$patchedAPK" /system/app/
adb shell chown root.root /system/app/EPubProd.apk
adb shell chmod 644 /system/app/EPubProd.apk
adb shell chcon u:object_r:system_file:s0 /system/app/EPubProd.apk
adb shell mount -o remount,ro /system

