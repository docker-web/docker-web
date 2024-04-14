INIT() {
  if [ $# -eq 0 ]
  then
    local $1=$(pwd)
  else
    mkdir -p $1
  fi
  local NAME=$(basename $FOLDER)

  cp $PATH_DOCKERWEB/template/* $1/
  cp $PATH_DOCKERWEB/template/.* $1/ > /dev/null 2>&1

  sed -i "s|__PORT__|$(GET_LAST_PORT)|g" $1/config.sh
  sed -i "s|__SERVICE_NAME__|$NAME|g" $1/docker-compose.yml
  sed -i "s|__SERVICE_NAME__|$NAME|g" $1/README.md
  sed -i "s|__SERVICE_NAME__|$NAME|g" $1/config.sh
  sed -i "s|DOMAIN=.*|DOMAIN=\"$NAME.\$MAIN_DOMAIN\"|g" $1/config.sh
}
