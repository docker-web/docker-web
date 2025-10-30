SETUP_PROXY() {
  local PATH_PROXY_COMPOSE="$PATH_DOCKERWEB_APPS/proxy/docker-compose.yml"

  # Installer proxy si nécessaire
  if [[ ! -d "$PATH_DOCKERWEB_APPS/proxy/" ]]; then
    echo "[INFO] proxy non installé, téléchargement depuis le store..."
    if [[ " ${APPS_STORE[*]} " =~ " proxy " ]]; then
      DL "proxy"
    else
      echo "[x] proxy non trouvé dans le store"
      return 1
    fi
  fi

  REMOVE_LINE $AUTO_GENERATED_STAMP $PATH_FILE_REDIRECTION

  rm -rf "$PATH_DOCKERWEB_APPS/proxy/$FILENAME_REDIRECTION"  # delete old redirections
  touch "$PATH_DOCKERWEB_APPS/proxy/$FILENAME_REDIRECTION"
  REMOVE_LINE $AUTO_GENERATED_STAMP $PATH_PROXY_COMPOSE

  for PATH_APP in $PATH_DOCKERWEB_APPS/*
  do
    local NAME_APP=$(basename $PATH_APP)
    NAME_APP=$(echo $NAME_APP | sed "s%/%%g")
    [[ -f "$PATH_APP/$FILENAME_ENV" ]] && source "$PATH_APP/$FILENAME_ENV"
    SETUP_REDIRECTIONS $NAME_APP
    SETUP_NGINX $NAME_APP
  done

  local NEW_LINE="      - $PATH_DOCKERWEB_APPS/proxy/$FILENAME_REDIRECTION:/etc/nginx/conf.d/$FILENAME_REDIRECTION $AUTO_GENERATED_STAMP"
  INSERT_LINE_AFTER "docker.sock:ro" "$NEW_LINE" "$PATH_PROXY_COMPOSE"

  EXECUTE "up -d" "proxy"
}
