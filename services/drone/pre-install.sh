#!/bin/bash

# switch between http / https dev / prod
IS_PEGAZDEV=$2
[[ $IS_PEGAZDEV == "false" ]] && sed -i "s|PROTO=.*|PROTO=\"https\"|g" "$PATH_PEGAZ_SERVICES/$1/config.sh"

# drone config
RPC_SECRET=$(openssl rand -hex 16)
sed -i "s/RPC_SECRET=.*/RPC_SECRET=\"$RPC_SECRET\"/" "$PATH_PEGAZ_SERVICES/$1/config.sh"
