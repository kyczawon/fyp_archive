#!/bin/bash
text=$(./escape_text.sh $@)
adb shell input tap $((16#362)) $((16#10b)) #click search
adb shell input text "$text"
adb shell input keyevent 66