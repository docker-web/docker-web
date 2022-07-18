#!/bin/bash
sudo useradd git
GIT_UID=$(id -u git)
GIT_GID=$(id -g git)

[[ $IS_PEGAZDEV == "false" ]] && sed -i "s|PROTO=.*|PROTO=\"https\"|g" "$PATH_PEGAZ_SERVICES/$1/config.sh"
