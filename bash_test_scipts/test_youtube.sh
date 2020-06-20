#!/bin/bash
./open_browser.sh 'youtube.com'
sleep 1
./navigate_youtube_video.sh "4K VIDEO ultrahd hdr sony 4K VIDEOS demo test nature relaxation movie for 4k oled tv"
sleep 1
adb shell input tap $((16#1d6)) $((16#478)) #select video
sleep 2
adb shell input tap $((16#20a)) $((16#265)) #click in the middle of video
sleep 1
adb shell input tap $((16#3e8)) $((16#364)) #full screen
sleep 10
adb shell input keyevent 4
sleep 1
adb shell input tap $((16#20a)) $((16#265)) #click in the middle of video
adb shell input tap $((16#20a)) $((16#265)) #stop