#!/bin/bash

# switch between http / https dev / prod
IS_DOCKERWEBDEV=$2
CONFIG_PATH="~/.drone-runner-exec/config"
[[ $IS_DOCKERWEBDEV == "false" ]] && sed -i "s|PROTO=.*|PROTO=\"https\"|g" "$PATH_DOCKERWEBDEV_SERVICES/$1/config.sh"
[[ $IS_DOCKERWEBDEV == "false" && -f "$CONFIG_PATH" ]] && sed -i "s|DRONE_RPC_=.*|DRONE_RPC_=\"https\"|g" $CONFIG_PATH

# drone config
RPC_SECRET=$(openssl rand -hex 16)
sed -i "s/RPC_SECRET=.*/RPC_SECRET=\"$RPC_SECRET\"/" "$PATH_DOCKERWEBDEV_SERVICES/$1/config.sh"
[[ -f "$CONFIG_PATH" ]] && sed -i "s/DRONE_RPC_SECRET=.*/DRONE_RPC_SECRET=\"$RPC_SECRET\"/" $CONFIG_PATH
