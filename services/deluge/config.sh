#!/bin/bash
export IMAGE="linuxserver/deluge:2.1.1"
export DOMAIN="deluge.$MAIN_DOMAIN"
export PORT="8112"
export PORT_EXPOSED="8112"
export REDIRECTIONS=""
export POST_INSTALL_TEST_CMD="docker exec deluge ls"
