INIT() {
  local TEMPLATE_NAME
  local APP_NAME=$1
  local CURRENT_FOLDER="."
  local IS_TEMPLATE_EXIST=$(find "$PATH_TEMPLATE" -mindepth 1 -maxdepth 1 -type d -name "$2" | grep -q . && echo "true" || echo "false")

  # $1 & $2 plein : APP_NAME=$1 TEMPLATE=$2 || "default"
  # $2 vide : APP_NAME=$CURRENT_FOLDER_NAME TEMPLATE=$1 || "default"
  # $1 & $2 vide TEMPLATE="default" APP_NAME=$CURRENT_FOLDER_NAME

  # type
  [[ "$IS_TEMPLATE_EXIST" == "true" ]] && TEMPLATE_NAME="$2" || TEMPLATE_NAME="default"


  # copy
  cp -r "$PATH_TEMPLATE/$TEMPLATE_NAME"/* $CURRENT_FOLDER
  cp -r "$PATH_TEMPLATE/$TEMPLATE_NAME"/.??* $CURRENT_FOLDER

  # port
  local PORT=$(ALLOCATE_PORT)
  echo "[*] Local port allocated: $PORT"
  sed -i "s|__PORT__|$PORT|g" "$CURRENT_FOLDER/docker-compose.yml"

  # name
  if [[ -n "$APP_NAME" ]]; then
    sed -i "s|app-name|$APP_NAME|g" "$CURRENT_FOLDER/docker-compose.yml"
    sed -i "s|app-name|$APP_NAME|g" "$CURRENT_FOLDER/README.md"
    sed -i "s|app-name|$APP_NAME|g" "$CURRENT_FOLDER/env.sh"
    sed -i "s|DOMAIN=.*|DOMAIN=\"$APP_NAME.\$MAIN_DOMAIN\"|g" "$CURRENT_FOLDER/env.sh"
  fi
  echo "[√] init $APP_NAME done"
}
