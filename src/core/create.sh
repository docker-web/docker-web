CREATE() {
  if test $2
  then
    local NAME=$1
    local IMAGE=$2
  elif test $1
  then
    local NAME=$1
    local IMAGE=$(docker search $1 --limit 1 --format "{{.Name}}")
  else
    while [[ !" ${APPS_FLAT} " =~ " $NAME " || ! $NAME ]]
    do
      echo "[?] Name"
      read NAME
    done
    local DELIMITER=") "
    local MAX_RESULT=7
    local LINE=0
    local RESULTS=$(docker search $NAME --limit $MAX_RESULT --format "{{.Name}}" | nl -w2 -s "$DELIMITER")
    while [[ $LINE -lt 1 || $LINE -gt $MAX_RESULT ]]
    do
      printf "$RESULTS\n"
      read LINE
    done
    IMAGE=$(sed -n ${LINE}p <<< "$RESULTS" 2> /dev/null)
    IMAGE=${IMAGE/ $LINE$DELIMITER/}
  fi

  [[ " ${APPS_FLAT} " =~ " $NAME " ]] && echo "[x] app $NAME already exist" && exit 1

  #ports setup
  local PORT=$(GET_LAST_PORT)
  PORT=$(($PORT + 2))
  docker pull $IMAGE
  [[ $? != 0 ]] && echo "[x] cant pull $IMAGE" && exit 1
  local PORT_EXPOSED=$(docker inspect --format='{{.Config.ExposedPorts}}' $IMAGE | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//')
  [[ $PORT_EXPOSED == "443" ]] && PORT_EXPOSED=$(docker inspect --format='{{.Config.ExposedPorts}}' $IMAGE | grep -o -E '[0-9]+' | head -2 | sed -e 's/^0\+//')

  [[ $PORT_EXPOSED == "" ]] && PORT_EXPOSED="80"

  #clean name
  NAME=${NAME//[^a-zA-Z0-9_]/}
  NAME=${NAME,,}

  #compose setup
  INIT $PATH_DOCKERWEB_APPS/$NAME

  sed -i "s|image:.*|image: $IMAGE|g" $PATH_DOCKERWEB_APPS/$NAME/docker-compose.yml
  sed -i "s|__APP_NAME__|$NAME|g" $PATH_DOCKERWEB_APPS/$NAME/docker-compose.yml
  sed -i "s|version: .*|version: $IMAGE|g" $PATH_DOCKERWEB_APPS/$NAME/README.md
  sed -i "s|PORT=.*|PORT=\"$PORT\"|g" $PATH_DOCKERWEB_APPS/$NAME/config.sh
  sed -i "s|PORT_EXPOSED=.*|PORT_EXPOSED=\"$PORT_EXPOSED\"|g" $PATH_DOCKERWEB_APPS/$NAME/config.sh

  if [ "$(basename "$WORK_DIR")" = "docker-web" ]
  then
    mkdir -p $WORK_DIR/apps/$NAME
    cp -r $PATH_DOCKERWEB_APPS/$NAME/* $WORK_DIR/apps/$NAME
  fi

  APPS=$(find $PATH_APPS -mindepth 1 -maxdepth 1 -not -name '.*' -type d -exec basename {} \; | sort | sed '/^$/d') # update apps list
  UP $NAME
  [[ $? != 0 ]] && echo "[x] create fail" && exit 1
}
