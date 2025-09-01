ALLOCATE_PORT() {
  local TYPE="$1"
  local MIN_PORT
  local MAX_RANGE
  local USED_PORTS=()

  # Définir la plage de ports selon le type
  if [ "$TYPE" == "store" ]; then
    MIN_PORT=7700
    MAX_RANGE=7800
  else
    MIN_PORT=7900
    MAX_RANGE=8000
  fi

  # Ports locaux
  for APP in "$PATH_DOCKERWEB_APPS"/*; do
    [[ ! -d "$APP" ]] && continue
    local PORT=$(sed -n 's/^PORT="\(.*\)"/\1/p' "$APP/config.sh")
    [[ $PORT =~ ^[0-9]+$ ]] && [[ $PORT -ne 0 ]] && [[ $PORT -ne 9091 ]] && USED_PORTS+=($PORT)
  done

  # Ports du store
  if command -v jq >/dev/null 2>&1; then
    local STORE_INDEX_URL="$URL_DOCKERWEB_STORE/index.json"
    local STORE_PORTS=$(curl -s "$STORE_INDEX_URL" | jq -r '.apps[].port // empty')
    for p in $STORE_PORTS; do
      [[ $p =~ ^[0-9]+$ ]] && [[ $p -ne 0 ]] && [[ $p -ne 9091 ]] && USED_PORTS+=($p)
    done
  fi

  # Déterminer le port disponible
  local PORT=$MIN_PORT
  while [[ " ${USED_PORTS[@]} " =~ " $PORT " ]]; do
    ((PORT+=2))
    if (( PORT > MAX_RANGE )); then
      echo "Erreur: plus de port disponible dans la plage $MIN_PORT-$MAX_RANGE" >&2
      return 1
    fi
  done

  # Prompt for remote port check
  if [ "$TYPE" != "store" ]; then
    read -p "[?] Check if port $PORT is available on a remote server? [y/N] " CHECK_REMOTE
    if [[ "$CHECK_REMOTE" =~ ^[Yy]$ ]]; then
      read -p "   > Enter remote host (user@host): " SSH_REMOTE

      while ssh "$SSH_REMOTE" "ss -tln | grep -q \":$PORT \""; do
        # echo "[!] Port $PORT is taken on $SSH_REMOTE"
        # Find next free port on server
        PORT=$((PORT + 1))
      done
      # echo "[√] Port $PORT is free on $SSH_REMOTE"
    fi
  fi

  echo $PORT
}
