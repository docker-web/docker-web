#!/bin/bash

set -a && source .env && set +a

changeEnvVar() {
  local var_name="$1"
  local new_value="$2"
  local env_file=".env"
  
  if grep -q "^${var_name}=" "$env_file"; then
    sed -i "s|${var_name}=.*|${var_name}=${new_value}|" "$env_file"
  else
    echo "${var_name}=${new_value}" >> "$env_file"
  fi
}

# Variables GitHub
APP_NAME="${GITHUB_REPOSITORY##*/}"
BRANCH_NAME=$GITHUB_REF_NAME

# Configuration pour les branches non-principales
if [ "$BRANCH_NAME" != "main" ] && [ "$BRANCH_NAME" != "master" ]; then
  DOMAIN="$BRANCH_NAME.$DOMAIN"
  APP_NAME="${BRANCH_NAME}_${APP_NAME}"
  PORT=$(bash /var/docker-web/src/cli.sh ALLOCATE_PORT)
  sed -i "s|${GITHUB_REPOSITORY##*/}|$APP_NAME|g" docker-compose.yml
fi

changeEnvVar "DOMAIN" $DOMAIN
changeEnvVar "APP_NAME" $APP_NAME
changeEnvVar "PORT" $PORT
changeEnvVar "APP_DIR" "/var/docker-web/apps/$APP_NAME"

set -a && source .env && set +a
