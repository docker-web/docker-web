#!/bin/bash

GITEA() {
  docker exec -u git gitea gitea $1
}

SECRET=$(openssl rand -hex 16)

sleep 5
GITEA "admin create-user --admin --username $USERNAME --password $PASSWORD --email $EMAIL --must-change-password=false"
# sleep 5
# GITEA "auth add-oauth --name drone --provider drone-ci --custom-auth-url ${PROTO}://${SUBDOMAIN_DRONE}.${DOMAIN}/login --secret $SECRET"
