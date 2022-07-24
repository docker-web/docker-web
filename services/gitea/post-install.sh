#!/bin/bash

GITEA() {
  docker exec -u git gitea gitea $1
}

sleep 5
GITEA "admin create-user --admin --username $USERNAME --password $PASSWORD --email $EMAIL --must-change-password=false"

# Manuel Drone configuration :
# Create OAuth2 Applications via web ui
# Copy ID & SECRET to config.sh
# restart drone
# source config.sh && source services/gitea/config.sh && docker-compose -f services/gitea/docker-compose.yml up drone
