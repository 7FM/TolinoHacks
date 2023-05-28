#!/bin/sh

echo "Flashing the boot image"

fastboot flash boot "$patchedBootImage"
