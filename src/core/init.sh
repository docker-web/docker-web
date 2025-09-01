INIT() {
  local TYPE
  local NAME
  local FOLDER="."
  local TEMPLATE_URL

  if [ -n "$2" ]; then
    TYPE=$1
    NAME=$2
  else
    NAME=$1
  fi

  # Determine template to download
  if [[ -n "$TYPE" ]]; then
    # Try template-<type>
    TEMPLATE_URL="$URL_DOCKERWEB_STORE/archives/template-$TYPE.tar.gz"
    if ! curl --head --silent --fail "$TEMPLATE_URL" >/dev/null; then
    echo "[x] there's no template for: $TYPE"
      # fallback to default template
      exit
    fi
  else
    # default template if no type
    TEMPLATE_URL="$URL_DOCKERWEB_STORE/archives/template.tar.gz"
  fi

  echo "[*] Using template from $TEMPLATE_URL"

  # Download and extract template
  curl -L -o /tmp/template.tar.gz "$TEMPLATE_URL"
  tar -xzf /tmp/template.tar.gz -C "$FOLDER" --strip-components=1
  rm -f /tmp/template.tar.gz

  # Configure app
  local PORT=$(ALLOCATE_PORT)
  echo "[*] Local port allocated: $PORT"
  # Apply config replacements
  sed -i "s|__PORT__|$PORT|g" "$FOLDER/config.sh"

  if [[ -n "$NAME" ]]; then
    sed -i "s|__APP_NAME__|$NAME|g" "$FOLDER/docker-compose.yml"
    sed -i "s|__APP_NAME__|$NAME|g" "$FOLDER/README.md"
    sed -i "s|__APP_NAME__|$NAME|g" "$FOLDER/config.sh"
    sed -i "s|DOMAIN=.*|DOMAIN=\"$NAME.\$MAIN_DOMAIN\"|g" "$FOLDER/config.sh"
  fi
  echo "[√] init $NAME done"
}
