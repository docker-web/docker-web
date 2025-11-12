#!/bin/bash

# Configuration de l'application Nuxt
export APP_NAME="app-name"
export REPO_NAME="app-name"
export DOMAIN="${APP_NAME}.${MAIN_DOMAIN}"
export PORT=""
export PORT_EXPOSED="3000"

# Variables d'environnement pour Nuxt
export NUXT_PUBLIC_SITE_NAME="${APP_NAME}"
export NUXT_PUBLIC_SITE_URL="https://${DOMAIN}"

# Variables d'environnement supplémentaires
export ENV_VARS=(
  "NODE_ENV=production"
  "NITRO_PORT=3000"
  "NITRO_HOST=0.0.0.0"
  "TZ=Europe/Paris"
)
