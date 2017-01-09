#!/bin/bash

if [[ $EMULATOR == "" ]]; then
    EMULATOR="android-23"
    echo "Using default emulator $EMULATOR"
fi

if [[ $ARCH == "" ]]; then
    ARCH="x86"
    echo "Using default arch $ARCH"
fi
echo EMULATOR  = "Requested API: ${EMULATOR} (${ARCH}) emulator."
if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 $1
fi

# Run sshd
/usr/sbin/sshd
adb start-server

# Detect ip and forward ADB ports outside to outside interface
IP=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
socat tcp-listen:5037,bind=$IP,fork tcp:127.0.0.1:5037 &
socat tcp-listen:5554,bind=$IP,fork tcp:127.0.0.1:5554 &
socat tcp-listen:5555,bind=$IP,fork tcp:127.0.0.1:5555 &

# Set up and run emulator
if [[ $ARCH == *"x86"* ]]
then
    EMU="x86"
else
    EMU="arm"
fi

DID=$(expr $INDEX * 2 + 5554)
P=$(expr $INDEX + 4723)
BP=$(expr $INDEX + 4823)
IPA=$(ifconfig  | grep 'inet addr:'| cut -d: -f2 | awk '{ print $1}' | head -n 2 | tail -n 1)

sed -i -e 's/IPADDRESS/'"$IPA"'/' ./nodeconfig.json
sed -i -e 's/PORT/'"$P"'/' ./nodeconfig.json

#start appium and register the node
nohup appium --nodeconfig ./nodeconfig.json -p $P -bp $BP -U $DID > appium.log 2>&1

#create our AVD
echo "no" | /usr/local/android-sdk-linux/tools/android create avd -f -n test -t ${EMULATOR} -s "1536x2048" --abi default/${ARCH}
echo "no" | /usr/local/android-sdk-linux/tools/emulator64-${EMU} -avd test -sdcard qasdcard.img -noaudio -no-window -gpu off -verbose -qemu -usbdevice tablet
