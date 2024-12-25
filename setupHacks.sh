#!/bin/sh

set -o errexit
set -o nounset
set -ueo pipefail

# TWRP for Page 2: https://github.com/Ryogo-Z/tolino_ntx_6sl_twrp/releases

# Get updates from:
# https://mytolino.de/software-updates-tolino-ereader/
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
updatePath="${SCRIPTPATH}/update.zip"
unzipPath="${SCRIPTPATH}/update"
bootImage="${unzipPath}/boot.img"
oldBootImage="${SCRIPTPATH}/unpatchedBoot.img"
patchedBootImage="${unzipPath}/patchedBoot.img"

rm -rf "$unzipPath"
mkdir -p "$unzipPath"
# Extract the update.zip
unzip "$updatePath" -d "$unzipPath"

. ./helper/patchBootImage.sh

mv "$bootImage" "$oldBootImage"
mv "$patchedBootImage" "$bootImage"

# Get TWRP for Page 2: https://github.com/Ryogo-Z/tolino_ntx_6sl_twrp/releases
rm -f twrp.img
wget https://github.com/Ryogo-Z/tolino_ntx_6sl_twrp/releases/latest/download/twrp.img > /dev/null 2>&1
mv "${unzipPath}/recovery.img" old_recovery.img
# Add it to our custom crafted update
mv twrp.img "${unzipPath}/recovery.img"

. ./helper/patchEPubProd.sh

mv "$updatePath" "${SCRIPTPATH}/unPatchedUpdate.zip"
cd "$unzipPath"
zip -r "$updatePath" *
cd "$SCRIPTPATH"

read -p "Mount the tolino partition, copy our patched update.zip to it, reboot, and wait until adb is available. AFTER that press ENTER to continue!" </dev/tty

. ./helper/updateSettings.sh
. ./helper/cleanupAPKs.sh

# Reboot after we applied all desired changes
adb reboot
