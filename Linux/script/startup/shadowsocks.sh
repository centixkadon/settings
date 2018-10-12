#!/bin/bash

shadowsocks_normalstart() {
  screen -dmS sswebgui ~/All/script/sswebgui.sh -c sswebgui.yml
}

shadowsocks_realstart() {
  screen -dmS sswebgui ~/All/script/sswebgui.sh -c sswebguireal.yml
}

shadowsocks_debugstart() {
  screen -dmS sswebgui ~/All/script/sswebgui.sh -c sswebguireal.yml --debug
}

shadowsocks_webguistop() {
  screen -S sswebgui -X quit
}

shadowsocks_start() {
  screen -dmS ssserver ~/All/script/ssserver.sh

  sleep 1
  screen -dmS sscount ~/All/script/sscount.sh
}

shadowsocks_stop() {
  screen -S sscount -X quit
  screen -S ssserver -X quit
}

case $1 in
start)
  shadowsocks_start
  shadowsocks_normalstart
  echo "$(date) | shadowsocks start" >> ~/All/log/systemctl.log
  ;;
realstart)
  shadowsocks_start
  shadowsocks_realstart
  echo "$(date) | shadowsocks realstart" >> ~/All/log/systemctl.log
  ;;
debugstart)
  shadowsocks_start
  shadowsocks_debugstart
  echo "$(date) | shadowsocks debugstart" >> ~/All/log/systemctl.log
  ;;
stop)
  shadowsocks_webguistop
  shadowsocks_stop
  echo "$(date) | shadowsocks stop" >> ~/All/log/systemctl.log
  ;;
restart)
  shadowsocks_webguistop
  shadowsocks_stop
  shadowsocks_start
  shadowsocks_normalstart
  echo "$(date) | shadowsocks restart" >> ~/All/log/systemctl.log
  ;;
normalrestart)
  shadowsocks_webguistop
  shadowsocks_normalstart
  echo "$(date) | shadowsocks normalrestart" >> ~/All/log/systemctl.log
  ;;
realrestart)
  shadowsocks_webguistop
  shadowsocks_realstart
  echo "$(date) | shadowsocks realrestart" >> ~/All/log/systemctl.log
  ;;
debugrestart)
  shadowsocks_webguistop
  shadowsocks_debugstart
  echo "$(date) | shadowsocks debugrestart" >> ~/All/log/systemctl.log
  ;;
*)
  echo "Usage: /etc/init.d/shadowsocks.sh {start|realstart|debugstart|stop|restart|normalrestart|realrestart|debugrestart}"
  ;;
esac
