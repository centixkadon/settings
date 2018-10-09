#!/bin/bash

sleep 1
screen -dmS ssserver ~/All/script/ssserver.sh

sleep 1
screen -dmS sscount ~/All/script/sscount.sh

echo "$(date) | shadowsocks start" >> systemctl.log
