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
patchedBootImage="${unzipPath}/patchedBoot.img"

rm -rf "$unzipPath"
mkdir -p "$unzipPath"
# Extract only the boot.img
unzip "$updatePath" "boot.img" -d "$unzipPath"

. ./helper/patchBootImage.sh

# install the latest twrp version
. ./helper/flashRecoveryImage.sh
. ./helper/flashBootImage.sh
# Exit fastboot mode again to establish an adb connection
fastboot reboot
# TODO wait for adb!
read -p "Wait until the tolino booted up and adb is available, then press Enter to continue" </dev/tty

. ./helper/updateSettings.sh
