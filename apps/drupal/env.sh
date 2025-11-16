#!/bin/bash
export APP_NAME="drupal"
export DOMAIN="${APP_NAME}.${MAIN_DOMAIN}"
export PORT="7712"
export PORT_EXPOSED="80"

export ENV_VARS=(
  "TZ=Europe/Paris"
  "PUID=1000"
  "PGID=1000"
)
