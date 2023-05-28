#!/bin/sh

set -o errexit
set -o nounset
set -ueo pipefail

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
unzipPath="${SCRIPTPATH}/update"
bootImage="${unzipPath}/boot.img"
patchedBootImage="${unzipPath}/patchedBoot.img"

# Get the currently installed boot image
mkdir -p "$unzipPath"
adb shell dd if=/dev/block/mmcblk0p1 of=/cache/boot.img
adb pull /cache/boot.img "$bootImage"
adb shell remove /cache/boot.img

. ./hepler/patchBootImage.sh

adb reboot recovery
# update to the latest twrp version
#. ./helper/flashRecoveryImage.sh
. ./helper/flashBootImage.sh
. ./helper/updateSettings.sh
