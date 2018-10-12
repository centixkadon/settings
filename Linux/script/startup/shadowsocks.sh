#!/bin/bash

case $1 in
"start")
  screen -dmS ssserver ~/All/script/ssserver.sh

  sleep 1
  screen -dmS sscount ~/All/script/sscount.sh
  screen -dmS sswebgui ~/All/script/sswebgui.sh

  echo "$(date) | shadowsocks start" >> ~/All/log/systemctl.log

  ;;
"stop")
  screen -S sswebgui -X quit
  screen -S sscount -X quit
  screen -S ssserver -X quit

  echo "$(date) | shadowsocks stop" >> ~/All/log/systemctl.log

  ;;
esac
