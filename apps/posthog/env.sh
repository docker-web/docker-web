#!/bin/bash
export APP_NAME="posthog"
export DOMAIN="${APP_NAME}.${MAIN_DOMAIN}"
export PORT="7714"
export PORT_EXPOSED="80"

export ENV_VARS=(
  "TZ=Europe/Paris"
  "PUID=1000"
  "PGID=1000"
  "SECRET_KEY=gwRBGBJuBeZheSYAi2QzzYv2mWPcd9s/tl3TsNCKpr4="
)
