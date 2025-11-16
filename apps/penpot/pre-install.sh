#!/bin/bash
# generate secret key once
if grep -q '^export SECRET_KEY=""' config.sh; then
    key=$(python3 -c "import secrets; print(secrets.token_urlsafe(64))")
    sed -i "s|^export SECRET_KEY=\"\"|export SECRET_KEY=\"$key\"|" config.sh
fi
