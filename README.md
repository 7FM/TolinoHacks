# How to enter fastboot mode
1. Connect your PC with the Tolino via USB.
2. Shut the Tolino down and wait approx. 5 seconds
3. Just keep holding the power button until fastboot finds the device (note this takes approx. 30s)

When fastboot is still stuck at:
```
< waiting for any device >
```
and the tolino is already booted, then make sure you have the required udev rules in place:
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
