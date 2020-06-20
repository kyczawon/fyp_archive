#!/bin/bash

set -e
set -o pipefail
adb shell getevent -l | grep ABS_MT_POSITION --line-buffered | awk '{print substr($0,54,8) END{print "\n"system("")};'
# adb shell getevent -l | grep ABS_MT_POSITION --line-buffered | awk '{print substr($0,54,8) system("")};' | head -n 2 > output_file.txt