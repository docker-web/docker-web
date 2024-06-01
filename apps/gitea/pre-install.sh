#!/bin/bash

sudo useradd git >/dev/null 2>&1
sudo chown -R git:git /home/git/

# switch between http / https dev / prod
IS_DOCKERWEBDEV=$2
[[ $IS_DOCKERWEBDEV == "false" ]] && sed -i "s|PROTO=.*|PROTO=\"https\"|g" "$PATH_DOCKERWEB_SERVICES/$1/config.sh"
echo $DOMAIN
sed -i "s|DOMAIN_GITEA=.*|DOMAIN_GITEA=\"$DOMAIN\"|g" "$PATH_DOCKERWEB_SERVICES/drone/config.sh"
