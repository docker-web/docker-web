#!/bin/bash
DARK_PATH_HTML="/usr/lib/python3.10/site-packages/deluge/ui/web/index.html"
DARK_INJECT='<link rel="stylesheet" type="text\/css" href="https:\/\/halianelf.github.io\/Deluge-Dark\/deluge.css">'
DARK_SEARCH="<\/head>"
docker exec deluge sed -i "/$DARK_SEARCH/i \ \t$DARK_INJECT" $DARK_PATH_HTML
