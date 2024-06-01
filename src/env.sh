export DOCKERWEB_VERSION="24.6.1"
export GITHUB_DOCKERWEB="https://github.com/docker-web/docker-web"
export PATH_DOCKERWEB=~/docker-web
export PATH_DOCKERWEB_APPS=$PATH_DOCKERWEB/apps
export PATH_DOCKERWEB_BACKUP=$PATH_DOCKERWEB/backup
export COMMANDS_CORE=$(ls -1 $PATH_DOCKERWEB/src/core/ | sed 's/\..*$//' | tr '\n' ' ')
export COMMANDS_APP=$(ls -1 $PATH_DOCKERWEB/src/apps/ | sed 's/\..*$//' | tr '\n' ' ')
export COMMANDS_COMPOSE="build bundle config create down events exec help images kill pause port ps pull push restart rm run start stop top unpause up version"
export COMMANDS="$COMMANDS_CORE $COMMANDS_APP $COMMANDS_COMPOSE"
export FILENAME_CONFIG="config.sh"
export FILENAME_ENV=".env"
export FILENAME_NGINX="nginx.conf"
export FILENAME_REDIRECTION="redirection.conf"
export FILENAME_PREINSTALL="pre-install.sh"
export FILENAME_POST_INSTALL="post-install.sh"
export AUTO_GENERATED_STAMP="#autogenerated"
export PUID="1000"
export PGID="1000"
export APPS=$(find $PATH_DOCKERWEB_APPS -mindepth 1 -maxdepth 1 -not -name '.*' -type d -exec basename {} \; | sort | sed '/^$/d')
export APPS_FLAT=$(echo $APPS | tr '\n' ' ')
