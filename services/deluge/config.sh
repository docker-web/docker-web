#!/bin/bash
export DOMAIN="deluge.$MAIN_DOMAIN"
export PORT="8112"
export PORT_EXPOSED="8112"
export REDIRECTIONS="torrent.$MAIN_DOMAIN->deluge.$MAIN_DOMAIN torrents.$MAIN_DOMAIN->deluge.$MAIN_DOMAIN"
export POST_INSTALL_TEST_CMD="docker exec deluge ls"
export JELLYFIN_API_KEY=""