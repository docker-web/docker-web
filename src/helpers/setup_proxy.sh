SETUP_PROXY() {
  [[ -f "$PATH_DOCKERWEB/$FILENAME_CONFIG" ]] && source "$PATH_DOCKERWEB/$FILENAME_CONFIG" || echo "[x] no docker-web main config file"
  PATH_PROXY_COMPOSE="$PATH_DOCKERWEB_SERVICES/proxy/docker-compose.yml"

  rm -rf "$PATH_DOCKERWEB_SERVICES/proxy/$FILENAME_REDIRECTION"  # delete old redirections
  sed -i "\|$PATH_DOCKERWEB_SERVICES|d" "$PATH_PROXY_COMPOSE"    # delete old vhosts
  for PATH_SERVICE in $PATH_DOCKERWEB_SERVICES/*
  do
    local NAME_SERVICE=$(basename $PATH_SERVICE)
    NAME_SERVICE=$(echo $NAME_SERVICE | sed "s%/%%g")
    [[ -f "$PATH_SERVICE/$FILENAME_CONFIG" ]] && source "$PATH_SERVICE/$FILENAME_CONFIG"
    SETUP_REDIRECTIONS $NAME_SERVICE
    SETUP_NGINX $NAME_SERVICE
  done

  local NEW_LINE="      - $PATH_DOCKERWEB_SERVICES/proxy/$FILENAME_REDIRECTION:/etc/nginx/conf.d/$FILENAME_REDIRECTION"
  INSERT_LINE_AFTER "docker.sock:ro" "$NEW_LINE" "$PATH_PROXY_COMPOSE"

  EXECUTE "up -d" "proxy"
}
