#!/bin/bash

# Run sshd
/usr/sbin/sshd
adb start-server

/usr/bin/Xvfb :1 -screen 0 2560x1800x24 &
export DISPLAY=:1
#echo 'display is set'

echo "no" | /usr/local/android-sdk-linux/tools/ export QEMU_AUDIO_DRV=none && ./emulator -avd Nexus9&
echo "Started emulator"

SENTINEL=0
while [[ "$SENTINEL" -lt 1 ]] 
do
    DEVICE=$(adb devices | grep 'device' | cut -d'4' -f2 |tail -n +2 | awk '{print $1}')
    if [[ "$DEVICE" = "device" ]] 
then
        let SENTINEL=SENTINEL+1
    fi
done

RUN cd /usr/local/android-sdk-linux/tools/ \
	&& export QEMU_AUDIO_DRV=none && ./emulator -avd Nexus -no-window &

sleep 30
mono /runner/automation.xactimate.Android/Android/Tests/bin/USRelease/Tests.exe $ONE $TWO $THREE
sleep 120