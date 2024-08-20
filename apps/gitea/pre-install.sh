#!/bin/bash

sudo useradd git >/dev/null 2>&1
sudo chown -R git:git /home/git/

# switch between http / https
[[ $MAIN_DOMAIN != "domain.local" ]] && sed -i "s|PROTO=.*|PROTO=\"https\"|g" "$PATH_DOCKERWEB_APPS/$1/config.sh"
[[ $MAIN_DOMAIN != "domain.local" ]] && sed -i '/#uncomment-for-prod /d' $"$PATH_DOCKERWEB_APPS/$1/docker-compose.yml"

sed -i "s|DOMAIN_GITEA=.*|DOMAIN_GITEA=\"$DOMAIN\"|g" "$PATH_DOCKERWEB_APPS/drone/config.sh"
