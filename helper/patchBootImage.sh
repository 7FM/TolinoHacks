#!/bin/sh

echo "Patching the boot image"

mntPoint="${SCRIPTPATH}/mnt"
rm -rf "$mntPoint"
mkdir -p "$mntPoint"

# Unpack the boot image
unpack_bootimg --format=mkbootimg -0 --boot_img "$bootImage" --out "$mntPoint" | tee mkbootimg_args > /dev/null
declare -a MKBOOTIMG_ARGS=()
while IFS= read -r -d '' ARG; do
  MKBOOTIMG_ARGS+=("${ARG}")
done < mkbootimg_args
rm mkbootimg_args

# Unpack the ramdisk
ramdiskDir="${mntPoint}/ramdiskExtracted"
rm -rf "$ramdiskDir"
mkdir -p "$ramdiskDir"
gzip -dcq "${mntPoint}/ramdisk" | cpio -i -d --no-absolute-filenames -D "$ramdiskDir"

# Patch the boot image
# Disable read only protection of the boot image
sed -i 's/ro.secure=.*$/ro.secure=0/' "${ramdiskDir}/default.prop"
# Enable debug mode
sed -i 's/ro.debuggable=.*$/ro.debuggable=1/' "${ramdiskDir}/default.prop"
# Enable adb while the device is in normal mode
sed -i 's/persist.sys.usb.config=.*$/persist.sys.usb.config=mass_storage,adb/' "${ramdiskDir}/default.prop"
# Enable the ADB service
grep "persist.service.adb.enable=" "${ramdiskDir}/default.prop" || echo "persist.service.adb.enable=1" >> "${ramdiskDir}/default.prop"
sed -i 's/persist.service.adb.enable=.*$/persist.service.adb.enable=1/' "${ramdiskDir}/default.prop"
# Enable adb root mode
sed -i 's/setprop ro.adb.secure.*$/setprop ro.adb.secure 0/' "${ramdiskDir}/init.rc"

# Patch the sbin/adbd binary to allow executing as root
# similar to: https://cweiske.de/tagebuch/android-root-adb.htm

# First compile the binary_patcher
(cd tools/binary_patcher && make)
# Then run it
./tools/binary_patcher/build/binary_patcher "${ramdiskDir}/sbin/adbd" "${ramdiskDir}/sbin/adbd_patched"
mv "${ramdiskDir}/sbin/adbd" "${mntPoint}/adbd_unpatched"
chmod +x "${ramdiskDir}/sbin/adbd_patched"
mv "${ramdiskDir}/sbin/adbd_patched" "${ramdiskDir}/sbin/adbd"

# Repack the ramdisk
# NOTE: it is extremely important to be inside the ramdiskDir! Otherwise `find` returns a prefix and an invalid ramdisk will be created!
cd "$ramdiskDir"
find . | cpio -H newc -o 2>/dev/null | gzip --best > "${mntPoint}/ramdisk.new"
mv "${mntPoint}/ramdisk" "${mntPoint}/ramdisk.old"
mv "${mntPoint}/ramdisk.new" "${mntPoint}/ramdisk"
cd "${SCRIPTPATH}"

# Repack the boot image
mkbootimg "${MKBOOTIMG_ARGS[@]}" -o "$patchedBootImage"
