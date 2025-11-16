#!/bin/bash
# switch between http / https dev / prod
[[ $MAIN_DOMAIN != "domain.local" ]] && sed -i "s|PROTO=.*|PROTO=\"https\"|g" "$PATH_DOCKERWEB_APPS/$1/config.sh"
