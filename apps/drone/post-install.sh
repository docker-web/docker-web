#!/bin/bash
echo "[i] see $PATH_DOCKERWEB_SERVICES/$1/post-install.sh to configure drone"
# Manual Drone configuration :
# Create OAuth2 Applications via web ui:
# name: drone, redirect uri: https://drone.domain.com/login
# Copy ID & SECRET to config.sh
# re-launch drone:
# docker-web up drone
