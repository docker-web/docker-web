#!/bin/bash
sed -i "s|__URL_TV__|$URL_TV|g" "$PATH_APPS/ersatztv/tv.html"
docker cp "$PATH_APPS/ersatztv/tv.html" "tv:/usr/share/nginx/html/index.html" > /dev/null
