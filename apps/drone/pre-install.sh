#!/bin/bash
# switch between http / https
[[ $MAIN_DOMAIN != "domain.local" ]] && sed -i "s|PROTO=.*|PROTO=\"https\"|g" "$PATH_DOCKERWEB_APPS/$1/config.sh"
[[ $MAIN_DOMAIN != "domain.local" ]] && sed -i 's/#uncomment-for-prod //g' "$PATH_DOCKERWEB_APPS/$1/docker-compose.yml"
