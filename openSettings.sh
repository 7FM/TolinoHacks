#!/bin/sh

set -o errexit
set -o nounset
set -ueo pipefail

adb shell am start -n com.android.settings/.Settings
