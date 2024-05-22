INIT() {
  if [ $# -eq 0 ]
  then
    local FOLDER=$(pwd)
  else
    local FOLDER=$1
    mkdir -p $FOLDER
  fi
  local NAME=$(basename $FOLDER)

  cp $PATH_DOCKERWEB/template/* $FOLDER/
  cp $PATH_DOCKERWEB/template/.* $FOLDER/ > /dev/null 2>&1

  sed -i "s|__PORT__|$(GET_LAST_PORT)|g" $FOLDER/config.sh
  sed -i "s|__APP_NAME__|$NAME|g" $FOLDER/docker-compose.yml
  sed -i "s|__APP_NAME__|$NAME|g" $FOLDER/README.md
  sed -i "s|__APP_NAME__|$NAME|g" $FOLDER/config.sh
  sed -i "s|DOMAIN=.*|DOMAIN=\"$NAME.\$MAIN_DOMAIN\"|g" $FOLDER/config.sh
}
