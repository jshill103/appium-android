#!/bin/bash

setsid launch-emualtor.sh >/dev/null 2>&1 < /dev/null &

sleep 30

mono Tests.exe $CMD1 $CMD2 $CMD3