#!/bin/bash
SSL=$(echo $(printf '%s\n' $(openssl rand -base64 64)) | sed 's/ /\\ /g')
sed -i -e "s|replaced-by-pre-install|$SSL|g" "$PATH_PEGAZ_SERVICES/$1/docker-compose.yml"
