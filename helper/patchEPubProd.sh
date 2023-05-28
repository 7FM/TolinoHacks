#!/bin/sh

echo "Patching the EPubProd APK"

# NOTE: the name may not be altered
patchedAPK="${SCRIPTPATH}/EPubProd.apk"
patchFolder="${SCRIPTPATH}/apkPatches"
apkDecomDir="${SCRIPTPATH}/EPubProdDecomp"

# Obtain the EPubProd.apk
cd "${SCRIPTPATH}"
adb pull /system/app/EPubProd.apk
hash=`sha256sum EPubProd.apk`
cp EPubProd.apk "EPubProd_${hash}.apk"
echo "Backing up unpatched EPubProd.apk as EPubProd_${hash}.apk"

# Decompile APK
rm -rf "$apkDecomDir"
mkdir -p "$apkDecomDir"
cd "$apkDecomDir"
apktool d -k -m -f "$patchedAPK"
cd EPubProd
# Improve some menu names
sed -i 's/To my books/Library/g' "res/values/strings.xml"
sed -i 's/My books/Library/g' "res/values/strings.xml"
sed -i 's/To my books/Library/g' "res/values-en/strings.xml"
sed -i 's/My books/Library/g' "res/values-en/strings.xml"

# Disable error reporting
sed -i 's/REPORT_ERRORS=.*$/REPORT_ERRORS=FALSE/' "assets/environments/app.properties.prod"
# Disabling some URLs
sed -i 's/FTU_COUNTRIES_RESELLERS_URL=.*$/FTU_COUNTRIES_RESELLERS_URL=0.0.0.0/' "assets/environments/app.properties.prod"
sed -i 's/FTU_REPORTING_SELECTED_RESELLER_URL=.*$/FTU_REPORTING_SELECTED_RESELLER_URL=0.0.0.0/' "assets/environments/app.properties.prod"
# sed -i 's/UPDATE_CHECK_URL=.*$/UPDATE_CHECK_URL=0.0.0.0/' "assets/environments/app.properties.prod"
sed -i 's/HOTSPOT_NETDATA_URL=.*$/HOTSPOT_NETDATA_URL=0.0.0.0/' "assets/environments/app.properties.prod"
# This one is needed to check whether we have an internet connection
# sed -i 's/PING_URL=.*$/PING_URL=0.0.0.0/' "assets/environments/app.properties.prod"
sed -i 's/INVENTORY_URL=.*$/INVENTORY_URL=0.0.0.0/' "assets/environments/app.properties.prod"
sed -i 's/FAMILY_URL=.*$/FAMILY_URL=0.0.0.0/' "assets/environments/app.properties.prod"
sed -i 's/FAMILY_RESELLERS_URL=.*$/FAMILY_RESELLERS_URL=0.0.0.0/' "assets/environments/app.properties.prod"
sed -i 's/FEEDBACK_URL=.*$/FEEDBACK_URL=0.0.0.0/' "assets/environments/app.properties.prod"
sed -i 's/LOST_DATA_RECOVERY_URL=.*$/LOST_DATA_RECOVERY_URL=0.0.0.0/' "assets/environments/app.properties.prod"
sed -i 's/RECOMMENDATIONS_URL=.*$/RECOMMENDATIONS_URL=0.0.0.0/' "assets/environments/app.properties.prod"

# Apply patches/changes
for i in "${patchFolder}"/*.patch; do
#   patch -d "$LOCAL_MANIFESTS_DIR" -p1 --binary -l < "$i";
  patch -p0 --binary -l < "$i";
done

# Compile APK again!
cd ..
apktool b EPubProd -c -f -o "$patchedAPK"

echo "Uploading patched EPubProd APK"
cd "${SCRIPTPATH}"

# Commands are taken from: https://www.mobileread.com/forums/showpost.php?p=3951131&postcount=18

adb shell mount -o remount,rw /system
adb push "$patchedAPK" /system/app/
adb shell chown root.root /system/app/EPubProd.apk
adb shell chmod 644 /system/app/EPubProd.apk
adb shell chcon u:object_r:system_file:s0 /system/app/EPubProd.apk
adb shell mount -o remount,ro /system

