SETUP_REDIRECTIONS() {
  local REDIRECTIONS=""
  SOURCE_APP "$1"

  # Si aucune redirection, ne rien faire
  [[ -z "$REDIRECTIONS" ]] && return

  local PATH_FILE_REDIRECTION="$PATH_DOCKERWEB_APPS/proxy/$FILENAME_REDIRECTION"
  local PATH_FILE_NGINX="$PATH_DOCKERWEB_APPS/$1/$FILENAME_NGINX"

  # Créer les fichiers si inexistants
  [[ ! -f "$PATH_FILE_NGINX" ]] && touch "$PATH_FILE_NGINX"
  [[ ! -f "$PATH_FILE_REDIRECTION" ]] && touch "$PATH_FILE_REDIRECTION"

  # Supprimer les anciennes lignes auto-générées
  REMOVE_LINE "$AUTO_GENERATED_STAMP" "$PATH_FILE_NGINX"
  REMOVE_LINE "$AUTO_GENERATED_STAMP" "$PATH_FILE_REDIRECTION"

  for REDIRECTION in $REDIRECTIONS; do
    local FROM=${REDIRECTION%->*}
    local TO=${REDIRECTION#*->}

    [[ $FROM == /* ]] && TYPE_FROM="route" || TYPE_FROM="domain"
    [[ $TO == /* ]] && TYPE_TO="route" || TYPE_TO="domain"
    [[ $TO == http* ]] && TYPE_TO="url"

    TYPE_FROM=$(REDIRECTION_TYPE "$FROM")
    TYPE_TO=$(REDIRECTION_TYPE "$TO")

    if [[ $TYPE_FROM == "route" ]]; then
      # /route->/route
      [[ $TYPE_TO == "route" ]] && echo "rewrite ^$FROM$ http://$DOMAIN$TO permanent; $AUTO_GENERATED_STAMP" >> "$PATH_FILE_NGINX"
      # /route->url
      [[ $TYPE_TO == "url" || $TYPE_TO == "domain" ]] && echo "rewrite ^$FROM$ $TO permanent; $AUTO_GENERATED_STAMP" >> "$PATH_FILE_NGINX"
      # domain->url/route/domain
    elif [[ $TYPE_FROM == "domain" ]]; then
      {
        echo "server {"
        echo "  server_name $FROM;"
        [[ $TYPE_TO == "route" ]] && echo "  return 301 http://$DOMAIN$TO;"
        [[ $TYPE_TO == "url" || $TYPE_TO == "domain" ]] && echo "  return 301 $TO;"
        echo "}"
        echo "$AUTO_GENERATED_STAMP"
      } >> "$PATH_FILE_REDIRECTION"
    fi
  done
}
