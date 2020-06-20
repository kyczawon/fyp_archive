#!/bin/bash
./open_browser.sh 'bbc.com'
sleep 4
declare -a arr=("google.com" "royalmail.com" "postoffice.co.uk" "baidu.com" "youtube.com")
for i in "${arr[@]}"
do
    ./open.sh $i
    sleep 4
done