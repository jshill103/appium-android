#!/bin/bash

# Run sshd
/usr/sbin/sshd
adb start-server

# Detect ip and forward ADB ports outside to outside interface
IP=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
socat tcp-listen:5037,bind=$IP,fork tcp:127.0.0.1:5037 &
socat tcp-listen:5554,bind=$IP,fork tcp:127.0.0.1:5554 &
socat tcp-listen:5555,bind=$IP,fork tcp:127.0.0.1:5555 &

DID=$(expr $INDEX \* 2 + 5554)

mv pix* ~/.android/avd

echo "no" | /usr/local/android-sdk-linux/tools/emulator64-x86 -avd pix -sdcard qasdcard.img -noaudio -no-window -gpu off -verbose -qemu -usbdevice tablet
echo "Started emulator"