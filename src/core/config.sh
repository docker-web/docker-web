CONFIG() {
  local CONFIG_PATH=$PATH_DOCKERWEB/config.sh
  source $CONFIG_PATH
  
  # Ensure config.sh has restricted permissions
  chmod 600 "$CONFIG_PATH"
  
  [[ -n $MAIN_DOMAIN ]] && echo "[?] domain [$MAIN_DOMAIN]:" || echo "[?] domain:"
  read NEW_MAIN_DOMAIN
  [[ -n $NEW_MAIN_DOMAIN ]] && sed -i "s|MAIN_DOMAIN=.*|MAIN_DOMAIN=\"$NEW_MAIN_DOMAIN\"|g" $CONFIG_PATH;

  [[ -n $USERNAME ]] && echo "[?] username [$USERNAME]:" || echo "[?] username:"
  read NEW_USERNAME
  [[ -n $NEW_USERNAME ]] && sed -i "s|USERNAME=.*|USERNAME=\"$NEW_USERNAME\"|g" $CONFIG_PATH

  echo "[?] password (input will be hidden):"
  read -s PASSWORD
  [[ -n $PASSWORD ]] && sed -i "s|PASSWORD=.*|PASSWORD=\"$PASSWORD\"|g" $CONFIG_PATH
  echo  # newline after silent input

  [[ $EMAIL == "user@domain.com" && -n $NEW_USERNAME && -n $NEW_MAIN_DOMAIN ]] && EMAIL="$NEW_USERNAME@$NEW_MAIN_DOMAIN"
  [[ -n $EMAIL ]] && echo "[?] email [$EMAIL]:" || echo "[?] email:"
  read NEW_EMAIL
  if [[ -n $NEW_EMAIL ]]
  then
    sed -i "s|EMAIL=.*|EMAIL=\"$NEW_EMAIL\"|g" $CONFIG_PATH
  else
    sed -i "s|EMAIL=.*|EMAIL=\"$EMAIL\"|g" $CONFIG_PATH
  fi

  echo "[?] media path [$MEDIA_DIR]:"
  read MEDIA_DIR_INPUT
  [[ -n $MEDIA_DIR_INPUT ]] && {
    [[ -d $MEDIA_DIR_INPUT ]] && sed -i "s|MEDIA_DIR=.*|MEDIA_DIR=\"$MEDIA_DIR_INPUT\"|g" $CONFIG_PATH || echo "[x] $MEDIA_DIR_INPUT doesn't exist"
  }
  
  # Ensure config is always restricted
  chmod 600 "$CONFIG_PATH"
  echo "[i] Configuration saved (permissions set to 600)"
}
