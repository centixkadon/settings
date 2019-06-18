#!/bin/bash

stty erase ^H

WARNH=$(echo -e "\033[0;1;31m")
WARNT=$(echo -e "\033[0m")

GITHUB_PATH=~/All/git/github
SETTINGS_PATH=${GITHUB_PATH}/centixkadon/settings


# config git

read -p "input git email: " GIT_EMAIL
read -p "input git name: " GIT_NAME
git config --global user.email "${GIT_EMAIL}"
git config --global user.name "${GIT_NAME}"


# server security

sudo apt install denyhosts


# centixkadon.github.io

mkdir -p ${GITHUB_PATH}/centixkadon
cd ${GITHUB_PATH}/centixkadon
git clone https://centixkadon@github.com/centixkadon/centixkadon.github.io.git


# Apache2

sudo apt install apache2
echo "${WARNH}[ToDo] change DocumentRoot in /etc/apache2/sites-available/000-default.conf${WARNT}"
echo "${WARNH}[ToDo] change <Directory> in /etc/apache2/apache2.conf${WARNT}"
echo "${WARNH}[ToDo] change ErrorDocument in /etc/apache2/conf-available/localized-error-pages.conf${WARNT}"
echo "${WARNH}[ToDo] change Alias & <Directory> in /etc/apache2/conf-available/javascript-common.conf${WARNT}"
read -sp "press Enter to continue..." && echo


# redis

sudo apt install redis-server
read -sp "config redis password: " REDIS_PASSWORD && echo
echo "${WARNH}[ToDo] uncomment requirepass in /etc/redis/redis.conf and change foobared to ${REDIS_PASSWORD}${WARNT}"
read -sp "press Enter to continue..." && echo
sudo systemctl restart redis.service


# shadowsocks

sudo apt install libsodium-dev npm sqlite3

mkdir -p ${GITHUB_PATH}/shadowsocks
cd ${GITHUB_PATH}/shadowsocks
git clone https://github.com/shadowsocks/shadowsocks.git
git clone https://github.com/shadowsocks/shadowsocks-manager.git

cd ${GITHUB_PATH}/shadowsocks/shadowsocks
git checkout master
echo "${WARNH}[ToDo] show self._config['server_port'] in logging ${WARNT}"
echo "${WARNH}[ToDo] add server_port in shadowsocks/shell.py exception_handle.process_exception.print_exception (vary from self_)${WARNT}"
echo "${WARNH}[ToDo] add server_port in shadowsocks/tcprelay.py TCPRelayHandler._handle_stage_addr.logging.info${WARNT}"
read -sp "press Enter to continue..." && echo
python3 setup.py build
sudo python3 setup.py install

sudo mkdir -p /etc/shadowsocks
sudo ln -sf ${SETTINGS_PATH}/shadowsocks/config.json /etc/shadowsocks/config.json

cd ${GITHUB_PATH}/shadowsocks/shadowsocks-manager
npm install
npm run build

read -sp "config shadowsocks-manager password: " SSMGR_PASSWORD && echo
mkdir -p ~/.ssmgr
cp ${SETTINGS_PATH}/shadowsocks/sscount.yml ~/.ssmgr/sscount.yml
sed -i 's/${PASSWORD}/'${SSMGR_PASSWORD}'/g' ~/.ssmgr/sscount.yml
cp ${SETTINGS_PATH}/shadowsocks/sswebgui.yml ~/.ssmgr/sswebgui.yml
sed -i 's/${PASSWORD}/'${SSMGR_PASSWORD}'/g' ~/.ssmgr/sswebgui.yml
cp ${SETTINGS_PATH}/shadowsocks/sswebguireal.yml ~/.ssmgr/sswebguireal.yml
sed -i '
  s/${PASSWORD}/'${SSMGR_PASSWORD}'/g
  s/${REDIS_PASSWORD}/'${REDIS_PASSWORD}'/g' ~/.ssmgr/sswebguireal.yml
echo "${WARNH}[ToDo] comment sendMail in plugins/email/index.js sendCode${WARNT}"
echo "${WARNH}[ToDo] comment throw in plugins/email/index.js checkCode & checkCodeFromTelegram${WARNT}"
echo "${WARNH}[ToDo] run \"~/All/scripts/sscount.sh\" in one terminal, and in another terminal${WARNT}"
echo "${WARNH}[ToDo] run \"~/All/scripts/sswebgui.sh -c sswebguireal.yml --debug\" first to register${WARNT}"
read -sp "press Enter to continue..." && echo


# copy scripts

ln -sf ${SETTINGS_PATH}/Linux/scripts ~/All/scripts
cd ~/All/scripts
sudo ln -sf ~/All/scripts/who-the-hell-is-using-the-server /usr/bin/who-the-hell-is-using-the-server
sudo ln -sf ~/All/scripts/who-the-hell-is-using-the-nvidia /usr/bin/who-the-hell-is-using-the-nvidia


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

sudo ln -sf ~/All/scripts/startup/shadowsocks.sh /etc/init.d/shadowsocks.sh
sudo cp ~/All/scripts/startup/shadowsocks.service /lib/systemd/system/shadowsocks.service
sudo sed -i '
  s/${USER}/'${SHADOWSOCKS_USER}'/g
  s/${GROUP}/'${SHADOWSOCKS_GROUP}'/g' /lib/systemd/system/shadowsocks.service
sudo systemctl enable shadowsocks.service


# log

mkdir -p ~/All/log

touch ~/All/log/systemctl.log
chmod +rw ~/All/log/systemctl.log

touch ~/All/log/shadowsocks.log
chmod +rw ~/All/log/shadowsocks.log
