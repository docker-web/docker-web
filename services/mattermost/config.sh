#!/bin/bash
export DOMAIN="mattermost.$MAIN_DOMAIN"
export PORT="7816"
export PORT_DB="7817"
export PORT_EXPOSED="8065"
export REDIRECTIONS=""

export MATTERMOST_CONFIG_PATH=./volumes/app/mattermost/config
export MATTERMOST_DATA_PATH=./volumes/app/mattermost/data
export MATTERMOST_LOGS_PATH=./volumes/app/mattermost/logs
export MATTERMOST_PLUGINS_PATH=./volumes/app/mattermost/plugins
export MATTERMOST_CLIENT_PLUGINS_PATH=./volumes/app/mattermost/client/plugins
export MATTERMOST_BLEVE_INDEXES_PATH=./volumes/app/mattermost/bleve-indexes

## Bleve index (inside the container)
export MM_BLEVESETTINGS_INDEXDIR=/mattermost/bleve-indexes
