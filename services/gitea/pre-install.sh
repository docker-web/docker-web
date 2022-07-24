#!/bin/bash

# switch between http / https dev / prod
[[ $IS_PEGAZDEV == "false" ]] && sed -i "s|PROTO=.*|PROTO=\"https\"|g" "$PATH_PEGAZ_SERVICES/$1/config.sh"

# drone config
DRONE_RPC_SECRET=$(openssl rand -hex 16)
sed -i "s/DRONE_RPC_SECRET=.*/DRONE_RPC_SECRET=\"$DRONE_RPC_SECRET\"/" "$PATH_PEGAZ_SERVICES/$1/config.sh"
