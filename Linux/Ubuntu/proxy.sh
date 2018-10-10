#!/bin/bash

stty erase ^H

case $1 in
"install")
  sudo apt install autossh
  ;;
"forward")
  read -p "ssh local user: " SSH_USER_LOCAL
  read -p "ssh local port: " SSH_PORT_LOCAL
  read -p "proxy local port: " PROXY_PORT_LOCAL
  read -p "proxy remote host: " PROXY_HOST_REMOTE
  read -p "proxy remote port: " PROXY_PORT_REMOTE
  ssh-keygen
  ssh-copy-id ${SSH_USER_LOCAL}@127.0.0.1 -p ${SSH_PORT_LOCAL}

  MY_GROUP=$(groups)
  sudo cp ~/All/script/startup/ssh_forward_proxy.service /lib/systemd/system/ssh_forward_proxy.service
  sudo sed -i '
    s/${USER}/'$(whoami)'/g
    s/${GROUP}/'${MY_GROUP%% *}'/g
    s/${PORT_LOCAL}/'${PROXY_PORT_LOCAL}'/g
    s/${HOST_REMOTE}/'${PROXY_HOST_REMOTE}'/g
    s/${PORT_REMOTE}/'${PROXY_PORT_REMOTE}'/g
    s/${SSH_USER}/'${SSH_USER_LOCAL}'/g
    s/${SSH_PORT}/'${SSH_PORT_LOCAL}'/g
    ' /lib/systemd/system/ssh_forward_proxy.service
  sudo systemctl enable ssh_forward_proxy.service

  ;;
"local")
  read -p "ssh local user: " SSH_USER_LOCAL
  read -p "ssh local port: " SSH_PORT_LOCAL
  read -p "proxy from this local port: " PROXY_PORT_FROM
  read -p "proxy to this local port: " PROXY_PORT_TO
  ssh-keygen
  ssh-copy-id ${SSH_USER_LOCAL}@127.0.0.1 -p ${SSH_PORT_LOCAL}

  MY_GROUP=$(groups)
  sudo cp ~/All/script/startup/ssh_forward_proxy.service /lib/systemd/system/ssh_forward_proxy.service
  sudo sed -i '
    s/${USER}/'$(whoami)'/g
    s/${GROUP}/'${MY_GROUP%% *}'/g
    s/${PORT_LOCAL}/'${PROXY_PORT_FROM}'/g
    s/${HOST_REMOTE}/127.0.0.1/g
    s/${PORT_REMOTE}/'${PROXY_PORT_TO}'/g
    s/${SSH_USER}/'${SSH_USER_LOCAL}'/g
    s/${SSH_PORT}/'${SSH_PORT_LOCAL}'/g
    ' /lib/systemd/system/ssh_forward_proxy.service
  sudo systemctl enable ssh_forward_proxy.service

  ;;
"reverse")
  read -p "ssh remote user: " SSH_USER_REMOTE
  read -p "ssh remote host: " SSH_HOST_REMOTE
  read -p "ssh remote port: " SSH_PORT_REMOTE
  read -p "proxy remote port: " PROXY_PORT_REMOTE
  read -p "proxy local port: " PROXY_PORT_LOCAL
  ssh-keygen
  ssh-copy-id ${SSH_USER_REMOTE}@${SSH_HOST_REMOTE} -p ${SSH_PORT_REMOTE}

  MY_GROUP=$(groups)
  sudo cp ~/All/script/startup/ssh_reverse_proxy.service /lib/systemd/system/ssh_reverse_proxy.service
  sed '
    s/${USER}/'$(whoami)'/g
    s/${GROUP}/'${MY_GROUP%% *}'/g
    s/${PORT_REMOTE}/'${PROXY_PORT_REMOTE}'/g
    s/${PORT_LOCAL}/'${PROXY_PORT_LOCAL}'/g
    s/${SSH_USER}/'${SSH_USER_REMOTE}'/g
    s/${SSH_HOST}/'${SSH_HOST_REMOTE}'/g
    s/${SSH_PORT}/'${SSH_PORT_REMOTE}'/g
    ' /lib/systemd/system/ssh_reverse_proxy.service
  sudo systemctl enable ssh_reverse_proxy.service

  ;;
*)
  echo "Args error!"
  echo "Usage:"
  echo "  $0 install"
  echo "  $0 forward"
  echo "  $0 local"
  echo "  $0 reverse"
  ;;
esac
