SETUP_REDIRECTIONS() {
  local REDIRECTIONS=""
  SOURCE_APP "$1"

  if [[ -n "$REDIRECTIONS" ]]; then
    PATH_FILE_REDIRECTION="$PATH_DOCKERWEB_APPS/proxy/$FILENAME_REDIRECTION"
    [[ ! -f "$PATH_FILE_REDIRECTION" ]] && touch "$PATH_FILE_REDIRECTION"
    
    REMOVE_LINE "$AUTO_GENERATED_STAMP" "$PATH_FILE_REDIRECTION"

    for REDIRECTION in $REDIRECTIONS; do
      local FROM=${REDIRECTION%->*}
      local TO=${REDIRECTION#*->}

      # Type de la source
      [[ $FROM == /* ]] && TYPE_FROM="route" || TYPE_FROM="domain"
      # Type de destination
      [[ $TO == /* ]] && TYPE_TO="route" || TYPE_TO=""
      [[ $TO == http* ]] && TYPE_TO="url"

      if [[ $TYPE_FROM == "route" ]]; then
        # /route -> /route
        [[ $TYPE_TO == "route" ]] && echo "rewrite ^$FROM$ http://$DOMAIN$TO permanent; $AUTO_GENERATED_STAMP" >> "$PATH_DOCKERWEB_APPS/$1/$FILENAME_NGINX"
        # /route -> url
        [[ $TYPE_TO == "url" ]] && echo "rewrite ^$FROM$ $TO permanent; $AUTO_GENERATED_STAMP" >> "$PATH_DOCKERWEB_APPS/$1/$FILENAME_NGINX"

      elif [[ $TYPE_FROM == "domain" ]]; then
        # Bloc HTTP
        echo "server {" >> "$PATH_FILE_REDIRECTION"
        echo "  listen 80;" >> "$PATH_FILE_REDIRECTION"
        echo "  server_name $FROM;" >> "$PATH_FILE_REDIRECTION"
        [[ $TYPE_TO == "route" ]] && echo "  return 301 http://$DOMAIN$TO;" >> "$PATH_FILE_REDIRECTION"
        [[ $TYPE_TO == "url" ]]   && echo "  return 301 $TO;" >> "$PATH_FILE_REDIRECTION"
        echo "}" >> "$PATH_FILE_REDIRECTION"

        # Bloc HTTPS
        echo "server {" >> "$PATH_FILE_REDIRECTION"
        echo "  listen 443 ssl;" >> "$PATH_FILE_REDIRECTION"
        echo "  server_name $FROM;" >> "$PATH_FILE_REDIRECTION"
        echo "  ssl_certificate /etc/nginx/certs/$FROM/fullchain.pem;" >> "$PATH_FILE_REDIRECTION"
        echo "  ssl_certificate_key /etc/nginx/certs/$FROM/key.pem;" >> "$PATH_FILE_REDIRECTION"
        [[ $TYPE_TO == "route" ]] && echo "  return 301 https://$DOMAIN$TO;" >> "$PATH_FILE_REDIRECTION"
        [[ $TYPE_TO == "url" ]]   && echo "  return 301 $TO;" >> "$PATH_FILE_REDIRECTION"
        echo "}" >> "$PATH_FILE_REDIRECTION"
      fi
    done
  fi
}
