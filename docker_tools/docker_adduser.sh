#!/usr/bin/env bash

echo_error(){
    echo -e "\e[91m[ERROR]$@\e[0m"
}

echo_info(){
    echo -e "\e[92m[INFO]$@\e[0m"
}


# update apt source
Codename=$(cat /etc/os-release | grep VERSION_CODENAME | awk -F'=' '{print $2}')
sourceweb='http://mirrors.aliyun.com'
cp /etc/apt/sources.list /etc/apt/sources.list.bak
echo "\
deb $sourceweb/ubuntu/ $Codename main restricted universe multiverse
deb $sourceweb/ubuntu/ $Codename-security main restricted universe multiverse
deb $sourceweb/ubuntu/ $Codename-updates main restricted universe multiverse
deb $sourceweb/ubuntu/ $Codename-proposed main restricted universe multiverse
deb $sourceweb/ubuntu/ $Codename-backports main restricted universe multiverse
#deb-src $sourceweb/ubuntu/ $Codename main restricted universe multiverse
#deb-src $sourceweb/ubuntu/ $Codename-security main restricted universe multiverse
#deb-src $sourceweb/ubuntu/ $Codename-updates main restricted universe multiverse
#deb-src $sourceweb/ubuntu/ $Codename-proposed main restricted universe multiverse
#deb-src $sourceweb/ubuntu/ $Codename-backports main restricted universe multiverse
">/etc/apt/sources.list
apt-get update 

if [ $? != 0 ]; then
    echo_error "apt update failed"
    exit -1
fi

# install base tools
DEBIAN_FRONTEND=noninteractive apt install -y sudo openssh-server openssh-client ssh vim make cmake gcc g++ curl git python3 wget unzip 

if [ $? != 0 ]; then
    echo_error "apt install failed"
    exit -1
fi

echo "
RSAAuthentication yes 
PubkeyAuthentication yes 
AuthorizedKeysFile .ssh/authorized_keys 
PermitRootLogin yes 
" >> /etc/ssh/sshd_config
service ssh restart


echo "root:ysu" | chpasswd
addgroup --gid "$DOCKER_GRP_ID" "$DOCKER_GRP" --force-badname
adduser --force-badname --gecos '' "$DOCKER_USER" --uid "$DOCKER_USER_ID" --gid "$DOCKER_GRP_ID" 2>/dev/null
echo "$DOCKER_USER:ysu" | chpasswd
usermod -aG sudo "$DOCKER_USER"
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
cp -r /etc/skel/. /home/${DOCKER_USER}
chown ${DOCKER_USER}:${DOCKER_GRP} /home/${DOCKER_USER}
ls -ad /home/${DOCKER_USER}/.??* | xargs chown -R ${DOCKER_USER}:${DOCKER_GRP}


Pwd=$( readlink -f "$( dirname $0 )" )
bash $Pwd/install_config.sh



