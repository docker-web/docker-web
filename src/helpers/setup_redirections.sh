SETUP_REDIRECTIONS() {
  unset REDIRECTIONS
  SOURCE_SERVICE $1
  if [[ $REDIRECTIONS != "" ]]
  then
    PATH_FILE_REDIRECTION="$PATH_DOCKERWEB_SERVICES/proxy/$FILENAME_REDIRECTION"
    [[ ! -f "$PATH_DOCKERWEB_SERVICES/$1/$FILENAME_NGINX" ]] && sudo touch "$PATH_DOCKERWEB_SERVICES/$1/$FILENAME_NGINX" $PATH_FILE_REDIRECTION
    REMOVE_LINE $AUTO_GENERATED_STAMP "$PATH_DOCKERWEB_SERVICES/$1/$FILENAME_NGINX"
    REMOVE_LINE $AUTO_GENERATED_STAMP $PATH_FILE_REDIRECTION
    for REDIRECTION in $REDIRECTIONS
    do
      local FROM=${REDIRECTION%->*}
      local TO=${REDIRECTION#*->}

      [[ $FROM == /* ]] && TYPE_FROM="route" || TYPE_FROM="domain"
      [[ $TO == /* ]] && TYPE_TO="route" || TYPE_TO=""
      [[ $TO == http* ]] && TYPE_TO="url"

      if [[ $TYPE_FROM == "route" ]]
      then
        # /route->/route
        [[ $TYPE_TO == "route" ]] && echo "rewrite ^$FROM$ http://$DOMAIN$TO permanent; $AUTO_GENERATED_STAMP" >> "$PATH_DOCKERWEB_SERVICES/$1/$FILENAME_NGINX"
        # /route->url
        [[ $TYPE_TO == "url" ]] && echo "rewrite ^$FROM$ $TO permanent; $AUTO_GENERATED_STAMP" >> "$PATH_DOCKERWEB_SERVICES/$1/$FILENAME_NGINX"
      elif [[ $TYPE_FROM == "domain" && $TYPE_FROM != "" ]]
      then
        echo "server {" >> $PATH_FILE_REDIRECTION
        echo "  server_name $FROM;" >> $PATH_FILE_REDIRECTION
        # domain->route
        [[ $TYPE_TO == "route" ]] && echo "  return 301 http://$DOMAIN$TO;" >> $PATH_FILE_REDIRECTION
        # domain->url
        [[ $TYPE_TO == "url" ]] && echo "  return 301 $TO;" >> $PATH_FILE_REDIRECTION
        echo "}" >> $PATH_FILE_REDIRECTION
      fi
    done
  fi
}
