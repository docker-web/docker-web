#!/bin/bash

# set LANG
LANGUAGE=${LANG%.*}
LANGUAGE=(${LANGUAGE/_/ })
LANGUAGE_LANG=${LANGUAGE[0]}
LANGUAGE_LOCAL=${LANGUAGE[1]}
sed -i "s:LANGUAGE_LANG:$LANGUAGE_LANG:g" "$PATH_PEGAZ_SERVICES/$1/librarie.json"
sed -i "s:LANGUAGE_LOCAL:$LANGUAGE_LOCAL:g" "$PATH_PEGAZ_SERVICES/$1/librarie.json"

curl -X POST -H "application/json" -d "MetadataCountryCode=$LANGUAGE_LOCAL&PreferredMetadataLanguage=$LANGUAGE_LANG&UICulture=$LANGUAGE_LANG-$LANGUAGE_LOCAL" "${SUBDOMAIN}.${DOMAIN}/Startup/Configuration"

# set User account
# curl -X POST -F "Name=$USERNAME" -F "Password=$PASSWORD" "${SUBDOMAIN}.${DOMAIN}/Startup/User"

# set Librarie
# curl -H "Content-Type: application/json" -d "$PATH_PEGAZ_SERVICES/$1/librarie.json" "${SUBDOMAIN}.${DOMAIN}/Library/VirtualFolders?collectionType=movies&refreshLibrary=false&name=Movies"
# curl -H "Content-Type: application/json" -F "EnableRemoteAccess=true" -F "EnableAutomaticPortMapping=false" "${SUBDOMAIN}.${DOMAIN}/Library/Startup/RemoteAccess"
