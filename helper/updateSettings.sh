#!/bin/sh

# Commands taken from: https://www.mobileread.com/forums/showpost.php?p=3950688&postcount=15

# NOTE: this should only be executed while in TWRP recovery mode!
echo "Updating settings"

adb shell mount /data || true
# Retrieve the settings database:
adb pull /data/data/com.android.providers.settings/databases/settings.db
adb pull /data/data/com.android.providers.settings/databases/settings.db-journal || true
cp settings.db settings_backup.db
# Update existing settings or insert it!
sqlite3 settings.db "UPDATE system SET value='24' WHERE name='time_12_24';"
sqlite3 settings.db "INSERT OR IGNORE INTO system (name, value) VALUES ('time_12_24', '24');"
# Note: the settings.db-journal file will be automatically deleted by SQLite, this is expected behavior. Also delete it from the device:
adb shell rm -f /data/data/com.android.providers.settings/databases/settings.db-journal || true
# Send the modified settings database back:
adb push settings.db /data/data/com.android.providers.settings/databases/
# Set the correct permissions and ownership metadata for the newly-uploaded file:
adb shell chown system.system /data/data/com.android.providers.settings/databases/settings.db
adb shell chmod 660 /data/data/com.android.providers.settings/databases/settings.db
rm -f settings.db
rm -f settings.db-journal
