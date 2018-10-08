#!/bin/bash

if [ "$(whoami)" == "root" ]
then # setup for root

# update && upgrade

apt update
apt upgrade --fix-missing
apt upgrade --fix-missing
apt upgrade --fix-missing

apt install build-essential python-pip python3-pip bash-completion vim git screen


# sshd port

SSH_PORT_DEFAULT=11122
read -p "SSH port (${SSH_PORT_DEFAULT}): " SSH_PORT
SSH_PORT=${SSH_PORT%% *}
SSH_PORT=${SSH_PORT%%.*}
SSH_PORT=${SSH_PORT:-${SSH_PORT_DEFAULT}}
echo "[Info] SSH port: ${SSH_PORT}"
echo

sed -ri.bak 's/ *#? *Port +[0-9]+/Port '${SSH_PORT}'/' /etc/ssh/sshd_config
/etc/init.d/ssh restart


# first user && group

USER_DEFAULT=cxd
read -p "First user (${USER_DEFAULT}): " SUDO_USER
SUDO_USER=${SUDO_USER%% *}
SUDO_USER=${SUDO_USER:-${USER_DEFAULT}}
echo "[Info] User: ${SUDO_USER}"
echo

read -p "First group (${SUDO_USER}): " USER_GROUP
USER_GROUP=${USER_GROUP%% *}
USER_GROUP=${USER_GROUP:-${SUDO_USER}}
echo "[Info] Group: ${USER_GROUP}"
echo

groupadd ${USER_GROUP}
useradd -m -g ${USER_GROUP} -G sudo -s /bin/bash ${SUDO_USER}
passwd ${SUDO_USER}

else # setup after root

GITHUB_PATH=~/All/git/github
mkdir -p ${GITHUB_PATH}/centixkadon
cd ${GITHUB_PATH}/centixkadon
git clone https://centixkadon@github.com/centixkadon/settings.git

cd ${GITHUB_PATH}/centixkadon/settings/Linux/Ubuntu
./setup.sh

fi
