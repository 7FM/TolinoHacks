#!/bin/sh

echo "Patching the EPubProd APK"

# NOTE: the name may not be altered
patchedAPK="${SCRIPTPATH}/EPubProd.apk"
patchFolder="${SCRIPTPATH}/apkPatches"
apkDecomDir="${SCRIPTPATH}/EPubProdDecomp"

# Obtain the EPubProd.apk
cd "${SCRIPTPATH}"
cp "${unzipPath}/system/app/EPubProd.apk" "EPubProd.apk"

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

cp "$patchedAPK" "${unzipPath}/system/app/EPubProd.apk"
