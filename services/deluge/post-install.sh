#!/bin/bash
DARK_PATH="/usr/lib/python3.11/site-packages/deluge/ui/web"
DARK_PATH_HTML="${DARK_PATH}/index.html"
DARK_INJECT='<link rel="stylesheet" type="text\/css" href="/css/deluge-dark.css">'
DARK_INJECT_2='<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1">'
DARK_SEARCH="<\/head>"

docker cp $PATH_PEGAZ_SERVICES/$1/css/deluge.css deluge:$DARK_PATH/css
docker cp $PATH_PEGAZ_SERVICES/$1/css/deluge-dark.css deluge:$DARK_PATH/css
docker cp $PATH_PEGAZ_SERVICES/$1/images deluge:$DARK_PATH/images

docker exec deluge sed -i "/deluge-dark.css/d" $DARK_PATH_HTML
docker exec deluge sed -i "/$DARK_SEARCH/i \ \t$DARK_INJECT" $DARK_PATH_HTML
docker exec deluge sed -i "/$DARK_SEARCH/i \ \t$DARK_INJECT_2" $DARK_PATH_HTML

docker cp $PATH_PEGAZ_SERVICES/$1/jellyfin_scan.sh deluge:/home
docker exec deluge chmod u+x torrent_completed.sh
