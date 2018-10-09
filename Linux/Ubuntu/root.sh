#!/bin/bash
# Download this script using bash:
#   wget -c https://raw.githubusercontent.com/centixkadon/settings/master/Linux/Ubuntu/root.sh
#   chmod +x root.sh
#   ./root.sh

stty erase ^H

WARNH=$(echo -e "\033[0;1;31m")
WARNT=$(echo -e "\033[0m")

if [ "$(whoami)" == "root" ]
then # setup for root

# update && upgrade

apt update
apt upgrade --fix-missing
apt upgrade --fix-missing

apt install build-essential python-pip python3-pip bash-completion vim git screen


# sshd port

SSH_PORT_DEFAULT=11122
read -p "SSH port (${SSH_PORT_DEFAULT}): " SSH_PORT
SSH_PORT=${SSH_PORT%% *}
SSH_PORT=${SSH_PORT%%.*}
SSH_PORT=${SSH_PORT:-${SSH_PORT_DEFAULT}}
echo "${WARNH}[Info] SSH port: ${SSH_PORT}${WARNT}"
echo

sed -ri.bak 's/ *#? *Port +[0-9]+/Port '${SSH_PORT}'/' /etc/ssh/sshd_config
/etc/init.d/ssh restart


# first user && group

USER_DEFAULT=cxd
read -p "First user (${USER_DEFAULT}) or press Ctrl+C to exit: " SUDO_USER
SUDO_USER=${SUDO_USER%% *}
SUDO_USER=${SUDO_USER:-${USER_DEFAULT}}
echo "${WARNH}[Info] User: ${SUDO_USER}${WARNT}"
echo

read -p "First group (${SUDO_USER}): " USER_GROUP
USER_GROUP=${USER_GROUP%% *}
USER_GROUP=${USER_GROUP:-${SUDO_USER}}
echo "${WARNH}[Info] Group: ${USER_GROUP}${WARNT}"
echo

groupadd ${USER_GROUP}
useradd -m -g ${USER_GROUP} -G sudo -s /bin/bash ${SUDO_USER}
passwd ${SUDO_USER}

cp /root/root.sh /home/${SUDO_USER}/root.sh
chown ${SUDO_USER}.${USER_GROUP} /home/${SUDO_USER}/root.sh

else # setup after root

GITHUB_PATH=~/All/git/github

mkdir -p ${GITHUB_PATH}/centixkadon
cd ${GITHUB_PATH}/centixkadon
git clone https://centixkadon@github.com/centixkadon/settings.git

cd ${GITHUB_PATH}/centixkadon/settings/Linux/Ubuntu
./setup.sh

fi
