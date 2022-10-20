#!/bin/bash
export IMAGE="nginx:1.23.2-alpine"
export DOMAIN="$MAIN_DOMAIN"
export PORT="7700"
export PORT_EXPOSED="80"
export REDIRECTIONS=""
export POST_INSTALL_TEST_CMD="pwd"
export SITE_TITLE="$MAIN_DOMAIN"
