# Features/Customizations
- Custom boot image to enable ADB (root)
- Get latest TWRP for Page 2 and flash it
- Rename `To my books`/`My books` to `Library`
- Enable 24h clock
- `EPubProd.apk`:
  - (decompile, apply patches from folder `apkPatches` and build again)
  - Disable reporting errors
  - Disable most calling home URLs (all except `UPDATE_CHECK_URL` and `PING_URL` to be able to find new updates)
  - Make secret developer debug option menus available: simply search for either `42` or `43` in your library
  - Remove the advertising/recommendation area (shrink to 1 pixel), though this somewhat ruins the home screen layout

# How to enter fastboot mode
1. Connect your PC with the Tolino via USB.
2. Shut the Tolino down and wait approx. 5 seconds
3. Just keep holding the power button until fastboot finds the device (note this takes approx. 30s)

When fastboot is still stuck at:
```
< waiting for any device >
```
and the tolino has already booted, then make sure you have the required udev rules in place:
```
# Tolino Page 2 in Fastboot mode
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="0d02", MODE="0666", GROUP="plugdev"
# Tolino Page 2 in ADB mode
SUBSYSTEM=="usb", ATTR{idVendor}=="1f85", ATTR{idProduct}=="6052", MODE="0666", GROUP="plugdev"
# Tolino Page 2 in TWRP recovery mode
SUBSYSTEM=="usb", ATTR{idVendor}=="1f85", ATTR{idProduct}=="6056", MODE="0666", GROUP="plugdev"
```
as explained [here](https://stackoverflow.com/a/53887437).

# How to enter recovery mode
1. **Unplug** your PC from the Tolino
2. Shut the Tolino down and wait approx. 5 seconds
3. Just keep holding the power button until the recovery screen or TWRP pops up

# Reading/Inspiration sources:
- https://www.mobileread.com/forums/showthread.php?t=327186
- https://cweiske.de/tagebuch/tag/tolino
- https://blog.mx17.net/2021/11/17/tolino-shine-3-patch-adbd-to-run-as-root/
