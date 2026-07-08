CONFIG() {
  local CONFIG_PATH=$PATH_DOCKERWEB/config.sh
  source $CONFIG_PATH
  
  # Ensure config.sh has restricted permissions
  chmod 600 "$CONFIG_PATH"
  
  [[ -n $MAIN_DOMAIN ]] && echo "[?] domain [$MAIN_DOMAIN]:" || echo "[?] domain:"
  read NEW_MAIN_DOMAIN
  [[ -n $NEW_MAIN_DOMAIN ]] && sed -i "s|MAIN_DOMAIN=.*|MAIN_DOMAIN=\"$NEW_MAIN_DOMAIN\"|g" $CONFIG_PATH;

  echo "[?] media path [$MEDIA_DIR]:"
  read MEDIA_DIR_INPUT
  [[ -n $MEDIA_DIR_INPUT ]] && {
    [[ -d $MEDIA_DIR_INPUT ]] && sed -i "s|MEDIA_DIR=.*|MEDIA_DIR=\"$MEDIA_DIR_INPUT\"|g" $CONFIG_PATH || echo "[x] $MEDIA_DIR_INPUT doesn't exist"
  }
  
  # Ensure config is always restricted
  chmod 600 "$CONFIG_PATH"
  echo "[i] Configuration saved (permissions set to 600)"
  echo "[i] Note: Each app manages its own authentication via web interfaces"
}
