#!/bin/bash
sed -i "s|__URL_TV__|$URL_TV|g" "$PATH_DOCKERWEB_APPS/ersatztv/tv.html"
docker cp "$PATH_DOCKERWEB_APPS/ersatztv/tv.html" "tv:/usr/share/nginx/html/index.html" > /dev/null
