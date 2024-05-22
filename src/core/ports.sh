PORTS() {
  APPS_PORTS=()
  for PATH_APP in $PATH_DOCKERWEB_APPS/*; do
    if [[ -f "$PATH_APP/$FILENAME_CONFIG" || -f "$PATH_APP/$FILENAME_ENV" ]]; then
      if [[ -f "$PATH_APP/$FILENAME_CONFIG" ]]; then
        SED_PREFIX="export PORT" && FILENAME=$FILENAME_CONFIG
      else
        SED_PREFIX="PORT" && FILENAME=$FILENAME_ENV
      fi
      CURRENT_PORT=$(sed -n "s/^$SED_PREFIX\(.*\)/\1/p" < "$PATH_APP/$FILENAME")
      CURRENT_PORT=$(echo "$CURRENT_PORT" | tr ' ' '\n' | grep -v '_EXPOSED=' | grep -o -E '[0-9]+' | sort -nr | head -n1)
    fi
    if [[ $CURRENT_PORT ]]; then
      APPS_PORTS+=("${CURRENT_PORT}: $(basename "$PATH_APP")")
    fi
  done

  IFS=$'\n' APPS_PORTS=($(sort <<<"${APPS_PORTS[*]}"))

  for app in "${APPS_PORTS[@]}"; do
    echo "$app"
  done
}
