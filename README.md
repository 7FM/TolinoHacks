When stuck at fastboot:
```
Trying to boot the latest recovery image
Please put your Tolino Page2 into fastboot mode!
< waiting for any device >
```
Then, ensure to add the required udev rule:
```
# Tolino Page 2 in Fastboot mode
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="0d02", MODE="0666", GROUP="plugdev"
# Tolino Page 2 in ADB mode
SUBSYSTEM=="usb", ATTR{idVendor}=="1f85", ATTR{idProduct}=="6052", MODE="0666", GROUP="plugdev"
# Tolino Page 2 in TWRP recovery mode
SUBSYSTEM=="usb", ATTR{idVendor}=="1f85", ATTR{idProduct}=="6056", MODE="0666", GROUP="plugdev"
```
as explained [here](https://stackoverflow.com/a/53887437).
