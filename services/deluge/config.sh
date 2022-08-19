#!/bin/bash
export IMAGE="linuxserver/deluge"
export SUBDOMAIN="deluge"
export PORT="7732"
export PORT_EXPOSED="8112"
export REDIRECTIONS=""
export POST_INSTALL_TEST_CMD="docker exec deluge ls"
