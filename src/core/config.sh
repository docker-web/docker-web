CONFIG() {
  local CONFIG_PATH=$PATH_DOCKERWEB/config.sh
  source $CONFIG_PATH
  [[ -n $MAIN_DOMAIN ]] && echo "[?] Domain [$MAIN_DOMAIN]:" || echo "[?] Domain:"
  read NEW_MAIN_DOMAIN
  [[ -n $NEW_MAIN_DOMAIN ]] && sed -i "s|MAIN_DOMAIN=.*|MAIN_DOMAIN=\"$NEW_MAIN_DOMAIN\"|g" $CONFIG_PATH;

  [[ -n $USERNAME ]] && echo "[?] Username [$USERNAME]:" || echo "[?] Username:"
  read NEW_USERNAME
  [[ -n $NEW_USERNAME ]] && sed -i "s|USERNAME=.*|USERNAME=\"$NEW_USERNAME\"|g" $CONFIG_PATH

  echo "[?] Password:"
  read -s PASSWORD
  [[ -n $PASSWORD ]] && sed -i "s|PASSWORD=.*|PASSWORD=\"$PASSWORD\"|g" $CONFIG_PATH

  [[ $EMAIL == "user@domain.com" && -n $NEW_USERNAME && -n $NEW_MAIN_DOMAIN ]] && EMAIL="$NEW_USERNAME@$NEW_MAIN_DOMAIN"
  [[ -n $EMAIL ]] && echo "[?] Email [$EMAIL]:" || echo "[?] Email:"
  read NEW_EMAIL
  if [[ -n $NEW_EMAIL ]]
  then
    sed -i "s|EMAIL=.*|EMAIL=\"$NEW_EMAIL\"|g" $CONFIG_PATH
  else
    sed -i "s|EMAIL=.*|EMAIL=\"$EMAIL\"|g" $CONFIG_PATH
  fi

  echo -e "[?] Media Path [$MEDIA_DIR]:"
  read MEDIA_DIR
  [[ -n $MEDIA_DIR ]] && {
    [[ -d $MEDIA_DIR ]] && sed -i "s|MEDIA_DIR=.*|MEDIA_DIR=\"$MEDIA_DIR\"|g" $CONFIG_PATH || echo "[x] $MEDIA_DIR doesn't exist"
  }

  # echo "[?] ZeroSSL API key (optional):"
  # read ZEROSSL_API_KEY
  # [[ -n $ZEROSSL_API_KEY ]] && sed -i "s|ZEROSSL_API_KEY=.*|ZEROSSL_API_KEY=\"$ZEROSSL_API_KEY\"|g" $CONFIG_PATH
}
