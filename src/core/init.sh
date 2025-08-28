INIT() {
  local TYPE="$1"
  local NAME="$2"
  local FOLDER
  local TEMPLATE_URL

  if [[ -z $NAME ]]; then
    FOLDER="."  # init dans le dossier courant
  else
    FOLDER="$PATH_DOCKERWEB_APPS/$NAME"
    mkdir -p "$FOLDER"
  fi

  # Determine template to download
  if [[ -n "$TYPE" ]]; then
    # Try template-<type>
    TEMPLATE_URL="$URL_DOCKERWEB_STORE/archives/template-$TYPE.tar.gz"
    if ! curl --head --silent --fail "$TEMPLATE_URL" >/dev/null; then
      # fallback to default template
      TEMPLATE_URL="$URL_DOCKERWEB_STORE/archives/template.tar.gz"
    else
      FOLDER="." # init in current folder if special template
    fi
  else
    TEMPLATE_URL="$URL_DOCKERWEB_STORE/archives/template.tar.gz"
  fi

  echo "[*] Using template from $TEMPLATE_URL"

  # Download and extract template
  curl -L -o /tmp/template.tar.gz "$TEMPLATE_URL"
  tar -xzf /tmp/template.tar.gz -C "$FOLDER" --strip-components=1
  rm -f /tmp/template.tar.gz

  # Configure app
  if [[ -n $NAME ]]; then
    local PORT=$(ALLOCATE_PORT)
    sed -i "s|__PORT__|$PORT|g" "$FOLDER/config.sh"
    sed -i "s|__APP_NAME__|$NAME|g" "$FOLDER/docker-compose.yml"
    sed -i "s|__APP_NAME__|$NAME|g" "$FOLDER/README.md"
    sed -i "s|__APP_NAME__|$NAME|g" "$FOLDER/config.sh"
    sed -i "s|DOMAIN=.*|DOMAIN=\"$NAME.\$MAIN_DOMAIN\"|g" "$FOLDER/config.sh"
  fi
}
