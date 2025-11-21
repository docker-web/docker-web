LS() {
  [[ -z $PATH_DOCKERWEB ]] && PATH_DOCKERWEB="/var/docker-web"

  printf "%-20s %-35s %-30s\n" "APP" "PORTS" "STATE"
  echo

  for APP in $APPS; do
    # Charger l'environement de l'app
    PORT="-"
    local ENV_FILE
    ENV_FILE=$(HAS_ENV_FILE "$PATH_APPS/$APP")
    [[ -n "$ENV_FILE" ]] && source "$ENV_FILE"
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
