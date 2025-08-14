#!/bin/bash
sed -i "s|__DOMAIN__|$DOMAIN|g" "$PATH_DOCKERWEB_APPS/ersatztv/tv.html"
docker cp "$PATH_DOCKERWEB_APPS/ersatztv/tv.html" "tv:/usr/share/nginx/html/index.html" > /dev/null
