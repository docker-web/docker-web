#!/bin/bash
DARK_PATH="/usr/lib/python3.10/site-packages/deluge/ui/web"
DARK_PATH_HTML="${DARK_PATH}/index.html"
DARK_INJECT='<link rel="stylesheet" type="text\/css" href="/css/deluge-dark.css">'
DARK_SEARCH="<\/head>"

docker cp $PATH_PEGAZ_SERVICES/$1/css/deluge.css deluge:$DARK_PATH/css
docker cp $PATH_PEGAZ_SERVICES/$1/css/deluge-dark.css deluge:$DARK_PATH/css

docker exec deluge sed -i "/deluge-dark.css/d" $DARK_PATH_HTML
docker exec deluge sed -i "/$DARK_SEARCH/i \ \t$DARK_INJECT" $DARK_PATH_HTML
