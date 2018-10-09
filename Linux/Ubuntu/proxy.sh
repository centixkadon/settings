#!/bin/bash

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
  sudo sed '
    s/${USER}/'$(whoami)'/
    s/${GROUP}/'${MY_GROUP%% *}'/
    s/${PORT_LOCAL}/'${PROXY_PORT_LOCAL}'/
    s/${HOST_REMOTE}/'${PROXY_HOST_REMOTE}'/
    s/${PORT_REMOTE}/'${PROXY_PORT_REMOTE}'/
    s/${SSH_USER}/'${SSH_USER_LOCAL}'/
    s/${SSH_PORT}/'${SSH_PORT_LOCAL}'/
    ' ~/All/script/startup/ssh_forward_proxy.service > /lib/systemd/system/ssh_forward_proxy.service
  sudo systemctl enable ssh_forward_proxy.service

  ;;
"local")
  read -p "ssh local user: " SSH_USER_LOCAL
  read -p "ssh local port: " SSH_PORT_LOCAL
  read -p "proxy from this local port: " PROXY_PORT_FROM
  read -p "proxy to this local port: " PROXY_PORT_TO
  ssh-keygen
  ssh-copy-id ${SSH_USER}@127.0.0.1 -p ${SSH_PORT}

  MY_GROUP=$(groups)
  sudo sed '
    s/${USER}/'$(whoami)'/
    s/${GROUP}/'${MY_GROUP%% *}'/
    s/${PORT_LOCAL}/'${PROXY_PORT_FROM}'/
    s/${HOST_REMOTE}/127.0.0.1/
    s/${PORT_REMOTE}/'${PROXY_PORT_TO}'/
    s/${SSH_USER}/'${SSH_USER_LOCAL}'/
    s/${SSH_PORT}/'${SSH_PORT_LOCAL}'/
    ' ~/All/script/startup/ssh_forward_proxy.service > /lib/systemd/system/ssh_forward_proxy.service
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
  sed '
    s/${USER}/'$(whoami)'/
    s/${GROUP}/'${MY_GROUP%% *}'/
    s/${PORT_REMOTE}/'${PROXY_PORT_REMOTE}'/
    s/${PORT_LOCAL}/'${PROXY_PORT_LOCAL}'/
    s/${SSH_USER}/'${SSH_USER_REMOTE}'/
    s/${SSH_HOST}/'${SSH_HOST_REMOTE}'/
    s/${SSH_PORT}/'${SSH_PORT_REMOTE}'/
    ' ~/All/script/startup/ssh_reverse_proxy.service > /lib/systemd/system/ssh_reverse_proxy.service
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
