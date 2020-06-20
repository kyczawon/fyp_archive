#!/bin/bash
adb shell input tap $((16#1b3)) $((16#7a))
adb shell input text "$1"
adb shell input keyevent 66