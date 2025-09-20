#!/bin/bash

CREATE() {
  local NAME IMAGE PORT PORT_EXPOSED

  # Gestion des arguments
  if [[ "$2" ]]; then
    NAME="$1"
    IMAGE="$2"
  elif [[ "$1" ]]; then
    NAME="$1"
    IMAGE=$(docker search "$NAME" --limit 1 --format "{{.Name}}")
  else
    # Prompt utilisateur si aucun argument
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

  # Vérifier existence app
  if [[ " ${APPS_FLAT[*]} " =~ " $NAME " ]]; then
    echo "[x] App $NAME already exists" >&2
    exit 1
  fi

  # Installer proxy si nécessaire
  if [[ ! -d "$PATH_DOCKERWEB_APPS/proxy" ]]; then
    echo "[INFO] proxy non installé, téléchargement depuis le store..."
    docker-web dl proxy || { echo "[x] Cannot install proxy"; exit 1; }
  fi

  # Ports
  PORT=$(ALLOCATE_PORT)
  PORT=$((PORT + 2))

  docker pull "$IMAGE" || { echo "[x] Cannot pull $IMAGE"; exit 1; }

  PORT_EXPOSED=$(docker inspect --format='{{range $p,$conf := .Config.ExposedPorts}}{{$p}} {{end}}' "$IMAGE" \
                  | grep -o -E '[0-9]+' | head -1)
  [[ -z $PORT_EXPOSED ]] && PORT_EXPOSED="80"

  # Nettoyage du nom
  NAME=${NAME//[^a-zA-Z0-9_]/}
  NAME=${NAME,,}

  # Init App
  FOLDER="$PATH_DOCKERWEB_APPS/$NAME"
  TEMPLATE_URL="$URL_DOCKERWEB_STORE/archives/template.tar.gz"

  mkdir -p "$FOLDER"
  echo "[*] Using template from $TEMPLATE_URL"
  # Download and extract template
  curl -L -o /tmp/template.tar.gz "$TEMPLATE_URL"
  tar -xzf /tmp/template.tar.gz -C "$FOLDER" --strip-components=1
  rm -f /tmp/template.tar.gz
  # Get port
  local PORT=$(ALLOCATE_PORT "store")
  echo "[*] Local port allocated: $PORT"

  # Modifier docker-compose et config.sh
  sed -i "s|image:.*|image: $IMAGE|g" "$PATH_DOCKERWEB_APPS/$NAME/docker-compose.yml"
  sed -i "s|app-name|$NAME|g" "$PATH_DOCKERWEB_APPS/$NAME/docker-compose.yml"
  sed -i "s|app-name|$NAME|g" "$FOLDER/README.md"
  sed -i "s|app-name|$NAME|g" "$FOLDER/config.sh"
  sed -i "s|DOMAIN=.*|DOMAIN=\"$NAME.\$MAIN_DOMAIN\"|g" "$FOLDER/config.sh"
  sed -i "s|version: .*|version: $IMAGE|g" "$PATH_DOCKERWEB_APPS/$NAME/README.md"
  sed -i "s|PORT=.*|PORT=\"$PORT\"|g" "$PATH_DOCKERWEB_APPS/$NAME/config.sh"
  sed -i "s|PORT_EXPOSED=.*|PORT_EXPOSED=\"$PORT_EXPOSED\"|g" "$PATH_DOCKERWEB_APPS/$NAME/config.sh"

  # Copier dans workspace si nécessaire
  if [[ "$(basename "$WORK_DIR")" == "docker-web" ]]; then
    mkdir -p "$WORK_DIR/apps/$NAME"
    cp -r "$PATH_DOCKERWEB_APPS/$NAME/"* "$WORK_DIR/apps/$NAME"
  fi

  # Mettre à jour liste apps
  APPS=$(find "$PATH_DOCKERWEB_APPS" -mindepth 1 -maxdepth 1 -type d -not -name '.*' -exec basename {} \; | sort)

  # Démarrer app
  UP "$NAME" || { echo "[x] Create failed"; exit 1; }
}
