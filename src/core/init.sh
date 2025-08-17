INIT() {
  # If no arguments are given, init creates a new app folder from template
  # in the current directory
  if [ $# -eq 0 ]
  then
    local FOLDER=$(pwd)
  else
  if [ $IS_DEVMODE ]
  then
    local FOLDER="apps/$1"
  else
    local FOLDER="$PATH_DOCKERWEB_APPS/$1"
  fi
    mkdir -p $FOLDER
  fi
  local NAME=$(basename $FOLDER)

  cp -R $PATH_DOCKERWEB/template/* $FOLDER/
  cp -R $PATH_DOCKERWEB/template/.github $FOLDER/ > /dev/null 2>&1

  sed -i "s|__PORT__|$(GET_LAST_PORT)|g" $FOLDER/config.sh
  sed -i "s|__APP_NAME__|$NAME|g" $FOLDER/docker-compose.yml
  sed -i "s|__APP_NAME__|$NAME|g" $FOLDER/README.md
  sed -i "s|__APP_NAME__|$NAME|g" $FOLDER/config.sh
  sed -i "s|DOMAIN=.*|DOMAIN=\"$NAME.\$MAIN_DOMAIN\"|g" $FOLDER/config.sh
}
