#!/bin/bash
export IMAGE="infiniteproject/icecast"
export DOMAIN="radio.$MAIN_DOMAIN"
export DOMAIN_LIQ="liq.$MAIN_DOMAIN"
export PORT="7727"
export PORT_EXPOSED="8000"
export PORT_LIQUIDSOAP="7728"
export MUSIC_DIR="$MEDIA_DIR"
export REDIRECTIONS="/->/live"
