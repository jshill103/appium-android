#!/bin/bash

# Run sshd
/usr/sbin/sshd
adb start-server

echo "no" | /usr/local/android-sdk-linux/tools/emulator64-x86 -avd pix -sdcard qasdcard.img -noaudio -no-window -gpu off -verbose -qemu -usbdevice tablet &
echo "Started emulator"
echo $CMD1
sleep 90

mono /runner/automation.xactimate.Android/Android/Tests/bin/USRelease/Tests.exe $CMD1 $CMD2 $CMD3