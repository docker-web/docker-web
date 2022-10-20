#!/bin/bash
export IMAGE="jellyfin/jellyfin:10.8.5"
export DOMAIN="jellyfin.$MAIN_DOMAIN"
export PORT="7712"
export PORT_EXPOSED="8096"
export REDIRECTIONS="play->/"
