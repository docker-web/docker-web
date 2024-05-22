#!/bin/bash

CONFIG_PATH="~/.drone-runner-exec/config"
[[ $MAIN_DOMAIN != "domain.local" ]] && sed -i "s|PROTO=.*|PROTO=\"https\"|g" "$PATH_DOCKERWEBDEV_APPS/$1/config.sh"
[[ $MAIN_DOMAIN != "domain.local" && -f "$CONFIG_PATH" ]] && sed -i "s|DRONE_RPC_=.*|DRONE_RPC_=\"https\"|g" $CONFIG_PATH

CONFIG_PATH="~/.drone-runner-exec/config"
[[ -f "$CONFIG_PATH" ]] && sed -i "s|DRONE_RPC_=.*|DRONE_RPC_=\"https\"|g" $CONFIG_PATH

# drone config
RPC_SECRET=$(openssl rand -hex 16)
sed -i "s/RPC_SECRET=.*/RPC_SECRET=\"$RPC_SECRET\"/" "$PATH_DOCKERWEB_APPS/$1/config.sh"
[[ -f "$CONFIG_PATH" ]] && sed -i "s/DRONE_RPC_SECRET=.*/DRONE_RPC_SECRET=\"$RPC_SECRET\"/" $CONFIG_PATH
