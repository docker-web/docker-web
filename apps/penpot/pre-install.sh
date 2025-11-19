#!/bin/bash
# generate secret key once
# si /var/docker-web/config.sh à PENPOT_SECRET vide, alors :
if [ -z "$PENPOT_SECRET" ]; then
    key=$(python3 -c "import secrets; print(secrets.token_urlsafe(64))")
    echo "export PENPOT_SECRET=\"$key\"" >> $PATH_DOCKERWEB/config.sh
fi
