#!/bin/bash
export VERSION="0.7"
export GITHUB_PEGAZ="https://github.com/valerebron/pegaz"
export PATH_PEGAZ="/opt/pegaz"
export PATH_PEGAZ_SERVICES="$PATH_PEGAZ/services"
export PATH_PEGAZ_BACKUP="$PATH_PEGAZ/backup"
export PATH_PEGAZ_VOLUME="$PATH_PEGAZ/volume"
export PATH_BASHRC="/etc/bash.bashrc"
export COMMANDS_CORE="config help port uninstall upgrade version ps create"
export COMMANDS_SERVICE="drop dune prune up start update reset logs backup restore state"
export COMMANDS_COMPOSE="build bundle config create down events exec help images kill pause port ps pull push restart rm run scale start stop top unpause up version"
export COMMANDS="$COMMANDS_CORE $COMMANDS_SERVICE $COMMANDS_COMPOSE"
export FILENAME_CONFIG="config.sh"
export FILENAME_NGINX="nginx.conf"
export FILENAME_REDIRECTION="redirection.conf"
export FILENAME_PREINSTALL="pre-install.sh"
export FILENAME_POSTINSTALL="post-install.sh"
export AUTO_GENERATED_STAMP="#autogenerated"
export PUID="1000"
export PGID="1000"
