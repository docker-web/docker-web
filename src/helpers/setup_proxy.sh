SETUP_PROXY() {
  PATH_PROXY_COMPOSE="$PATH_DOCKERWEB_APPS/proxy/docker-compose.yml"

  rm -rf "$PATH_DOCKERWEB_APPS/proxy/$FILENAME_REDIRECTION"  # delete old redirections
  sed -i "\|$PATH_DOCKERWEB_APPS|d" "$PATH_PROXY_COMPOSE"    # delete old vhosts
  for PATH_APP in $PATH_DOCKERWEB_APPS/*
  do
    local NAME_APP=$(basename $PATH_APP)
    NAME_APP=$(echo $NAME_APP | sed "s%/%%g")
    [[ -f "$PATH_APP/$FILENAME_CONFIG" ]] && source "$PATH_APP/$FILENAME_CONFIG"
    SETUP_REDIRECTIONS $NAME_APP
    SETUP_NGINX $NAME_APP
  done

  local NEW_LINE="      - $PATH_DOCKERWEB_APPS/proxy/$FILENAME_REDIRECTION:/etc/nginx/conf.d/$FILENAME_REDIRECTION"
  INSERT_LINE_AFTER "docker.sock:ro" "$NEW_LINE" "$PATH_PROXY_COMPOSE"

  EXECUTE "up -d" "proxy"
}
