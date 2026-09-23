#!/bin/bash

export APP_NAME="radio"
export DOMAIN="${APP_NAME}.${MAIN_DOMAIN}"

export PORT=""
export PORT_EXPOSED="8000"

export MUSIC_PATH="/mnt/hdd/music"

export ENV_VARS=(
  "TZ=Europe/Paris"
  "PUID=1000"
  "PGID=1000"
)
