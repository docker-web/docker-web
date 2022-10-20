#!/bin/bash
export IMAGE="nginx:1.23.2-alpine"
export DOMAIN="test.$MAIN_DOMAIN"
export PORT="7703"
export PORT_EXPOSED="80"
export REDIRECTIONS="from->/ /from->/"
