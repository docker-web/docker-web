INIT() {
  local TYPE
  local NAME
  local CURRENT_FOLDER="."
  local TEMPLATE_URL

  NAME=$1

  # type
  if [[ -n "$2" && -d "$PATH_DOCKERWEB/template/$2" ]]; then
    TYPE="$2"
  else
    TYPE="default"
  fi

  # copy
  cp -r "$PATH_DOCKERWEB/template/$TYPE"/* $CURRENT_FOLDER

  # port
  local PORT=$(ALLOCATE_PORT)
  echo "[*] Local port allocated: $PORT"
  sed -i "s|__PORT__|$PORT|g" "$CURRENT_FOLDER/docker-compose.yml"

  # name
  if [[ -n "$NAME" ]]; then
    sed -i "s|app-name|$NAME|g" "$CURRENT_FOLDER/docker-compose.yml"
    sed -i "s|app-name|$NAME|g" "$CURRENT_FOLDER/README.md"
    sed -i "s|app-name|$NAME|g" "$CURRENT_FOLDER/env.sh"
    sed -i "s|DOMAIN=.*|DOMAIN=\"$NAME.\$MAIN_DOMAIN\"|g" "$CURRENT_FOLDER/env.sh"
  fi
  echo "[√] init $NAME done"
}
