SETUP_NGINX() {
  if [[ $DOMAIN != *localhost:* ]]
  then
    if [[ -f "$PATH_DOCKERWEB_APPS/$1/$FILENAME_NGINX" ]]
    then
      if [[ -s "$PATH_DOCKERWEB_APPS/$1/$FILENAME_NGINX" ]]
      then
        local NEW_LINE="      - $PATH_DOCKERWEB_APPS/$1/$FILENAME_NGINX:/etc/nginx/vhost.d/${DOMAIN}_location $AUTO_GENERATED_STAMP"
        INSERT_LINE_AFTER "docker.sock:ro" "$NEW_LINE" "$PATH_PROXY_COMPOSE"
      fi
    fi
  fi
}
