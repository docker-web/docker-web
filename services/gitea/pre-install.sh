#!/bin/bash

if ! command -v sudo 1>/dev/null
then
    echo "[*] install sudo"
    command -v apt 1>/dev/null && apt update --allow-releaseinfo-change -y && apt -y install sudo
    command -v apk 1>/dev/null && apk update && apk add sudo
    command -v pacman 1>/dev/null && pacman -Sy --noconfirm sudo
    command -v yum 1>/dev/null && yum -y update && yum -y install sudo
fi

sudo useradd git >/dev/null 2>&1
sudo chown -R git:git /home/git/

# switch between http / https dev / prod
[[ $IS_PEGAZDEV == "false" ]] && sed -i "s|PROTO=.*|PROTO=\"https\"|g" "$PATH_PEGAZ_SERVICES/$1/config.sh"

# drone config
DRONE_RPC_SECRET=$(openssl rand -hex 16)
sed -i "s/DRONE_RPC_SECRET=.*/DRONE_RPC_SECRET=\"$DRONE_RPC_SECRET\"/" "$PATH_PEGAZ_SERVICES/$1/config.sh"
