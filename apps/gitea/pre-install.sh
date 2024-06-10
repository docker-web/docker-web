#!/bin/bash

sudo useradd -m git >/dev/null 2>&1
sudo chown -R git:git /home/git/

# switch between http / https dev / prod
[[ $MAIN_DOMAIN != "domain.local" ]] && sed -i "s|PROTO=.*|PROTO=\"https\"|g" "$PATH_DOCKERWEB_APPS/$1/config.sh"
