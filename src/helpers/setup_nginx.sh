SETUP_NGINX() {
  if [[ $DOMAIN != *localhost:* ]]
  then
    if [[ -f "$PATH_DOCKERWEB_SERVICES/$1/$FILENAME_NGINX" ]]
    then
      if [[ -s "$PATH_DOCKERWEB_SERVICES/$1/$FILENAME_NGINX" ]]
      then
        local NEW_LINE="      - $PATH_DOCKERWEB_SERVICES/$1/$FILENAME_NGINX:/etc/nginx/vhost.d/${DOMAIN}_location"
        INSERT_LINE_AFTER "docker.sock:ro" "$NEW_LINE" "$PATH_PROXY_COMPOSE"
      fi
    fi
  fi
}
