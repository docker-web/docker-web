PORTS() {
  SERVICES_PORTS=()
  for PATH_SERVICE in $PATH_DOCKERWEB_SERVICES/*; do
    if [[ -f "$PATH_SERVICE/$FILENAME_CONFIG" || -f "$PATH_SERVICE/$FILENAME_ENV" ]]; then
      if [[ -f "$PATH_SERVICE/$FILENAME_CONFIG" ]]; then
        SED_PREFIX="export PORT" && FILENAME=$FILENAME_CONFIG
      else
        SED_PREFIX="PORT" && FILENAME=$FILENAME_ENV
      fi
      CURRENT_PORT=$(sed -n "s/^$SED_PREFIX\(.*\)/\1/p" < "$PATH_SERVICE/$FILENAME")
      CURRENT_PORT=$(echo "$CURRENT_PORT" | tr ' ' '\n' | grep -v '_EXPOSED=' | grep -o -E '[0-9]+' | sort -nr | head -n1)
    fi
    if [[ $CURRENT_PORT ]]; then
      SERVICES_PORTS+=("${CURRENT_PORT}: $(basename "$PATH_SERVICE")")
    fi
  done

  IFS=$'\n' SERVICES_PORTS=($(sort <<<"${SERVICES_PORTS[*]}"))

  for service in "${SERVICES_PORTS[@]}"; do
    echo "$service"
  done
}
