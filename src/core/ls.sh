LS() {
  [[ -z $PATH_DOCKERWEB ]] && PATH_DOCKERWEB="/var/docker-web"
  [[ -z $FILENAME_CONFIG ]] && FILENAME_CONFIG="config.sh"

  printf "%-20s %-35s %-30s\n" "APP" "PORTS" "STATE"
  echo

  for APP in $APPS; do
    # Charger la config de l'app
    PORT="-"
    CONFIG_FILE="$PATH_DOCKERWEB_APPS/$APP/$FILENAME_CONFIG"
    [[ -f $CONFIG_FILE ]] && source "$CONFIG_FILE"
    [[ -n $PORT && $PORT != "0" ]] || PORT="-"

    # Récupérer l'état de l'app
    STATE="-"
    if declare -f GET_STATE >/dev/null 2>&1; then
      STATE=$(GET_STATE "$APP")
      [[ -z $STATE ]] && STATE="-"
    fi

    # Affichage final
    printf "%-20s %-35s %-30s\n" "$APP" "$PORT" "$STATE"
  done
}
