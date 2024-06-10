#!/bin/bash

sudo useradd git >/dev/null 2>&1
sudo chown -R git:git /home/git/

# switch between http / https dev / prod
[[ $MAIN_DOMAIN == "domain.local" ]] && sed -i "s|PROTO=.*|PROTO=\"https\"|g" "$PATH_DOCKERWEB_SERVICES/$1/config.sh"
sed -i "s|DOMAIN_GITEA=.*|DOMAIN_GITEA=\"$DOMAIN\"|g" "$PATH_DOCKERWEB_SERVICES/drone/config.sh"
