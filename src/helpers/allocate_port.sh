ALLOCATE_PORT() {
  local MIN_PORT=7700
  local USED_PORTS=()

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

  # Déterminer le port max et prendre le suivant pair
  local MAX_PORT=$MIN_PORT
  for p in "${USED_PORTS[@]}"; do
    (( p > MAX_PORT )) && MAX_PORT=$p
  done

  # On prend le prochain port pair supérieur
  local PORT=$((MAX_PORT + 2))
  echo $PORT
}
