#!/bin/bash
export DOMAIN="__SERVICE_NAME__.$MAIN_DOMAIN"
export PORT="7703"
export PORT_EXPOSED="80"
export REDIRECTIONS="example.$MAIN_DOMAIN->/route $MAIN_DOMAIN->url /route->/another-route /route->url"
