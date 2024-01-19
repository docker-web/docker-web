#!/bin/bash
echo "[i] see $PATH_PEGAZ_SERVICES/$1/post-install.sh to configure drone"
# Manual Drone configuration :
# Create OAuth2 Applications via web ui:
# name: drone, redirect uri: https://drone.domain.com/login
# Copy ID & SECRET to config.sh
# re-launch drone:
# pegaz up drone
# Install host exec runner
# curl -L https://github.com/drone-runners/drone-runner-exec/releases/latest/download/drone_runner_exec_linux_amd64.tar.gz | tar zx
# sudo install -t /usr/local/bin drone-runner-exec
# config
# /etc/drone-runner-exec/config
# DRONE_RPC_PROTO=https
# DRONE_RPC_HOST=drone.domain.com
# DRONE_RPC_SECRET=super-duper-secret
# DRONE_LOG_FILE=drone-runner-exec/log.txt
# start
# sudo drone-runner-exec service install
# sudo drone-runner-exec service start
# test
# cat /var/log/drone-runner-exec/log.txt
