
INIT() {
  local NAME="$1"
  local FOLDER

  if [[ -z $NAME ]]; then
    FOLDER="."  # init dans le dossier courant
  else
    FOLDER="$PATH_DOCKERWEB_APPS/$NAME"
    mkdir -p "$FOLDER"
  fi

  # Télécharger template depuis le store
  local STORE_URL="$URL_DOCKERWEB_STORE/archives/template.tar.gz"
  curl -L -o /tmp/template.tar.gz "$STORE_URL"
  tar -xzf /tmp/template.tar.gz -C "$FOLDER" --strip-components=1
  rm -f /tmp/template.tar.gz

  # Configurer l'app
  if [[ -n $NAME ]]; then
    local PORT=$(ALLOCATE_PORT)
    sed -i "s|__PORT__|$PORT|g" "$FOLDER/config.sh"
    sed -i "s|__APP_NAME__|$NAME|g" "$FOLDER/docker-compose.yml"
    sed -i "s|__APP_NAME__|$NAME|g" "$FOLDER/README.md"
    sed -i "s|__APP_NAME__|$NAME|g" "$FOLDER/config.sh"
    sed -i "s|DOMAIN=.*|DOMAIN=\"$NAME.\$MAIN_DOMAIN\"|g" "$FOLDER/config.sh"
  fi
}
