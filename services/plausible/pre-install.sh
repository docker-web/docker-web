#!/bin/bash
echo "pre install here"
echo "path: $PATH_PEGAZ_SERVICES"
echo $(pwd)
SSL=$(echo $(printf '%s\n' $(openssl rand -base64 64)) | sed 's/ /\\ /g')
sed -i "s|SECRET_KEY_BASE=.*|SECRET_KEY_BASE=\"$SSL\"|g" "$PATH_PEGAZ_SERVICES/$1/config.sh"
