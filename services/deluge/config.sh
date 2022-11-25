#!/bin/bash
export DOMAIN="deluge.$MAIN_DOMAIN"
export PORT="8112"
export PORT_EXPOSED="8112"
export REDIRECTIONS="torrent->/ torrents->/"
export POST_INSTALL_TEST_CMD="docker exec deluge ls"
