#!/bin/bash

CREATE() {
  local NAME IMAGE PORT PORT_EXPOSED ENV_FILE

  # image
  if [[ "$2" ]]; then
    IMAGE="$2"
  elif [[ "$1" ]]; then
    NAME="$1"
    IMAGE=$(docker search "$NAME" --limit 1 --format "{{.Name}}")
    if [ -z "$IMAGE" ]; then
      echo "[!] Aucune image trouvée avec le nom: $NAME"
      read -p "[?] Veuillez entrer le nom complet de l'image Docker: " IMAGE
      [ -z "$IMAGE" ] && { echo "[!] Aucune image spécifiée. Abandon."; return 1; }
    fi
  else
    while [[ -z $NAME || " ${APPS_FLAT[*]} " =~ " $NAME " ]]; do
      read -p "[?] App name: " NAME
    done
    local RESULTS=$(docker search "$NAME" --limit 7 --format "{{.Name}}" | nl -w2 -s ") ")
    local LINE=0
    while [[ $LINE -lt 1 || $LINE -gt 7 ]]; do
      printf "%s\n" "$RESULTS"
      read -p "[?] Choisir image: " LINE
    done
    IMAGE=$(sed -n "${LINE}p" <<< "$RESULTS" | awk '{print $2}')
  fi
  if [[ " ${APPS_FLAT[*]} " =~ " $NAME " ]]; then
    echo "[x] App $NAME already exists" >&2
    exit 1
  fi
  docker pull "$IMAGE" || { echo "[x] Cannot pull $IMAGE"; exit 1; }

  # port
  PORT=$(ALLOCATE_PORT)
  PORT_EXPOSED=$(docker inspect --format='{{range $p,$conf := .Config.ExposedPorts}}{{$p}} {{end}}' "$IMAGE" | grep -o -E '[0-9]+' | head -1)
  [[ -z $PORT_EXPOSED ]] && PORT_EXPOSED="80"

  # name
  NAME=${NAME//[^a-zA-Z0-9_]/}
  NAME=${NAME,,}

  # copy
  FOLDER="$PATH_APPS/$NAME"
  mkdir -p "$FOLDER"
  cp -R $PATH_DOCKERWEB/template/default/* $FOLDER

  # env
  ENV_FILE=$(HAS_ENV_FILE "$FOLDER")
  sed -i "s|image:.*|image: $IMAGE|g" "$PATH_APPS/$NAME/docker-compose.yml"
  sed -i "s|app-name|$NAME|g" "$PATH_APPS/$NAME/docker-compose.yml"
  sed -i "s|app-name|$NAME|g" "$FOLDER/README.md"
  sed -i "s|app-name|$NAME|g" "$ENV_FILE"
  sed -i "s|APP_NAME=.*|APP_NAME=\"$NAME\"|g" "$ENV_FILE"
  sed -i "s|version: .*|version: $IMAGE|g" "$PATH_APPS/$NAME/README.md"
  sed -i "s|PORT=.*|PORT=\"$PORT\"|g" "$ENV_FILE"
  sed -i "s|PORT_EXPOSED=.*|PORT_EXPOSED=\"$PORT_EXPOSED\"|g" "$ENV_FILE"

  # app
  APPS=$(find "$PATH_APPS" -mindepth 1 -maxdepth 1 -type d -not -name '.*' -exec basename {} \; | sort)
  UP "$NAME" || { echo "[x] Create failed"; exit 1; }
}
