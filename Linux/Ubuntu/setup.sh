#!/bin/bash

WARNH=$(echo -e "\033[0;1;31m")
WARNT=$(echo -e "\033[0m")

GITHUB_PATH=~/All/git/github
SETTINGS_PATH=${GITHUB_PATH}/centixkadon/settings


# server security

sudo apt install denyhosts


# centixkadon.github.io

mkdir -p ${GITHUB_PATH}/centixkadon
cd ${GITHUB_PATH}/centixkadon
git clone https://centixkadon@github.com/centixkadon/centixkadon.github.io.git


# Apache2

sudo apt install apache2
echo "${WARNH}[ToDo] change DocumentRoot in /etc/apache2/sites-available/000-default.conf${WARNT}"


# shadowsocks

sudo apt install libsodium-dev npm

mkdir -p ${GITHUB_PATH}/shadowsocks
cd ${GITHUB_PATH}/shadowsocks
git clone https://github.com/shadowsocks/shadowsocks.git
git clone https://github.com/shadowsocks/shadowsocks-manager.git

cd ${GITHUB_PATH}/shadowsocks/shadowsocks
chmod +x setup.py
./setup.py build
sudo ./setup.py install

sudo mkdir -p /etc/shadowsocks
sudo ln -sf ${SETTINGS_PATH}/shadowsocks/config.json /etc/shadowsocks/config.json

cd ${GITHUB_PATH}/shadowsocks/shadowsocks-manager
npm -i
ln -sf ${SETTINGS_PATH}/shadowsocks/sscount.yml ~/.ssmgr/sscount.yml
ln -sf ${SETTINGS_PATH}/shadowsocks/sswebgui.yml ~/.ssmgr/sswebgui.yml
echo "${WARNH}[ToDo] comment sendMail in sendCode${WARNT}"
echo "${WARNH}[ToDo] comment throw in sendCode & checkCode${WARNT}"


# copy script

ln -sf ${SETTINGS_PATH}/Linux/script ~/All/script
cd ~/All/script
sudo ln -sf ~/All/script/who-the-hell-is-using-the-server /usr/bin/who-the-hell-is-using-the-server
sudo ln -sf ~/All/script/who-the-hell-is-using-the-nvidia /usr/bin/who-the-hell-is-using-the-nvidia


# enable service

SHADOWSOCKS_USER_DEFAULT=$(whoami)
read -p "shadowsocks user (${SHADOWSOCKS_USER_DEFAULT}): " SHADOWSOCKS_USER
SHADOWSOCKS_USER=${SHADOWSOCKS_USER%% *}
SHADOWSOCKS_USER=${SHADOWSOCKS_USER:-${SHADOWSOCKS_USER_DEFAULT}}
echo "${WARNH}[Info] shadowsocks user: ${SHADOWSOCKS_USER}${WARNT}"
echo

SHADOWSOCKS_GROUP_DEFAULT=$(groups)
SHADOWSOCKS_GROUP_DEFAULT=${SHADOWSOCKS_GROUP_DEFAULT%% *}
read -p "shadowsocks group (${SHADOWSOCKS_USER_DEFAULT}): " SHADOWSOCKS_GROUP
SHADOWSOCKS_GROUP=${SHADOWSOCKS_GROUP%% *}
SHADOWSOCKS_GROUP=${SHADOWSOCKS_GROUP:-${SHADOWSOCKS_GROUP_DEFAULT}}
echo "${WARNH}[Info] shadowsocks group: ${SHADOWSOCKS_GROUP}${WARNT}"
echo

sudo ln -sf ~/All/script/startup/shadowsocks.sh /etc/shadowsocks/shadowsocks.sh
sudo sed '
  s/${USER}/'${SHADOWSOCKS_USER}'/
  s/${GROUP}/'${SHADOWSOCKS_GROUP}'/' ~/All/script/startup/shadowsocks.service > /lib/systemd/system/shadowsocks.service
sudo systemctl enable shadowsocks.service

touch ~/All/systemctl.log
chmod +rw ~/All/systemctl.log
