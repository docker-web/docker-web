#!/bin/bash
torrentid=$1
torrentname=$2
torrentpath=$3

curl -X POST jellyfin:8096/Library/Refresh?api_key=$JELLYFIN_API_KEY
