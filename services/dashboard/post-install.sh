#!/bin/bash
echo "[*] update dashboard"
FOLDER_WEB="$PATH_PEGAZ_SERVICES/dashboard/web"

echo "" > $FOLDER_WEB/index.html
echo "" > $FOLDER_WEB/body.html
sed -i "s|__TITLE__|$MAIN_DOMAIN|g" "$FOLDER_WEB/top.html"
cat "$FOLDER_WEB/top.html" >> "$FOLDER_WEB/index.html"

# SERVICES
for PATH_SERVICE in $PATH_PEGAZ_SERVICES/*
do
  NAME_SERVICE=$(basename $PATH_SERVICE)
  NAME_SERVICE=$(echo $NAME_SERVICE | sed "s%/%%g")

  unset DASHBOARD_HIDDEN
  unset DOMAIN
  unset REDIRECTIONS
  unset FROM
  unset TO

  [[ -f "$PATH_SERVICE/$FILENAME_CONFIG" ]] && source "$PATH_SERVICE/$FILENAME_CONFIG"
  [[ -f "$PATH_SERVICE/$FILENAME_ENV" ]] && source "$PATH_SERVICE/$FILENAME_ENV"
  [[ $DASHBOARD_HIDDEN == true ]] && continue
  if [[ $(docker ps -f "name=$NAME_SERVICE" -f "status=running" --format "{{.Names}}") ]]
  then
    # APPLICATION
    cp -a "$FOLDER_WEB/link.html" "$FOLDER_WEB/$NAME_SERVICE.html"
    sed -i "s|__LINK_TYPE__|application|g" "$FOLDER_WEB/$NAME_SERVICE.html"
    sed -i "s|__NAME__|$NAME_SERVICE|g" "$FOLDER_WEB/$NAME_SERVICE.html"
    sed -i "s|__DOMAIN__|$DOMAIN|g" "$FOLDER_WEB/$NAME_SERVICE.html"
    cat "$FOLDER_WEB/$NAME_SERVICE.html" >> "$FOLDER_WEB/body.html"
    if [[ -f "$PATH_SERVICE/logo.svg" ]]
    then
      docker exec dashboard test ! -f "/usr/share/nginx/html/$NAME_SERVICE.svg" && docker cp "$PATH_SERVICE/logo.svg" "dashboard:/usr/share/nginx/html/$NAME_SERVICE.svg"
    else
      docker cp "$PATH_PEGAZ/docs/pegaz.svg" "dashboard:/usr/share/nginx/html/$NAME_SERVICE.svg"
    fi
    # REDIRECTIONS
    if [[ $REDIRECTIONS != "" ]]
    then
      for REDIRECTION in $REDIRECTIONS
      do
        FROM=${REDIRECTION%->*}
        TO=${REDIRECTION#*->}

        [[ $FROM == /* ]] && TYPE_FROM="route" || TYPE_FROM="domain"
        [[ $TO == /* ]] && TYPE_TO="route" || TYPE_TO=""
        [[ $TO == http* ]] && TYPE_TO="url"
        
        if [[ $TYPE_FROM == "domain" && $TYPE_TO == "route" ]]
        then
          NAME_REDIRECTION=${FROM%%.*}
          cp -a "$FOLDER_WEB/link.html" "$FOLDER_WEB/$NAME_REDIRECTION.html"
          sed -i "s|__LINK_TYPE__|redirection|g" "$FOLDER_WEB/$NAME_REDIRECTION.html"
          sed -i "s|__NAME__|$NAME_REDIRECTION|g" "$FOLDER_WEB/$NAME_REDIRECTION.html"
          sed -i "s|__DOMAIN__|$DOMAIN$TO|g" "$FOLDER_WEB/$NAME_REDIRECTION.html"
          if [[ -f "$PATH_SERVICE/$NAME_REDIRECTION.svg" ]]
          then
            docker exec dashboard test ! -f "/usr/share/nginx/html/$NAME_REDIRECTION.svg" && docker cp "$PATH_SERVICE/$NAME_REDIRECTION.svg" "dashboard:/usr/share/nginx/html/$NAME_REDIRECTION.svg"
          else
            docker cp "$PATH_PEGAZ/docs/pegaz.svg" "dashboard:/usr/share/nginx/html/$NAME_REDIRECTION.svg"
          fi
          cat "$FOLDER_WEB/$NAME_REDIRECTION.html" >> "$FOLDER_WEB/body.html"
        fi
      done
    fi
  fi
done

# ALIASES
source "$PATH_PEGAZ_SERVICES/dashboard/$FILENAME_CONFIG"
if [[ $ALIASES ]]
then
  for ALIASE in $ALIASES
  do
    NAME_ALIAS=${ALIASE%->*}
    URL_ALIAS=${ALIASE#*->}
    cp -a "$FOLDER_WEB/link.html" "$FOLDER_WEB/$NAME_ALIAS.html"
    sed -i "s|__LINK_TYPE__|alias|g" "$FOLDER_WEB/$NAME_ALIAS.html"
    sed -i "s|__NAME__|$NAME_ALIAS|g" "$FOLDER_WEB/$NAME_ALIAS.html"
    sed -i "s|__DOMAIN__|$URL_ALIAS|g" "$FOLDER_WEB/$NAME_ALIAS.html"
    [[ ! -f "dashboard:/usr/share/nginx/html/$NAME_ALIAS.svg" ]] && docker cp "$PATH_PEGAZ/docs/pegaz.svg" "dashboard:/usr/share/nginx/html/$NAME_ALIAS.svg"
    cat "$FOLDER_WEB/$NAME_ALIAS.html" >> "$FOLDER_WEB/body.html"
  done
fi

[[ $(cat "$FOLDER_WEB/body.html") == "" ]] && cat "$FOLDER_WEB/empty.html" >> "$FOLDER_WEB/body.html"

cat "$FOLDER_WEB/body.html" >> "$FOLDER_WEB/index.html"
cat "$FOLDER_WEB/bottom.html" >> "$FOLDER_WEB/index.html"

docker cp "$FOLDER_WEB/index.html" "dashboard:/usr/share/nginx/html/"
docker exec dashboard test ! -f /usr/share/nginx/html/pegaz.svg && docker cp "$PATH_PEGAZ/docs/pegaz.svg" "dashboard:/usr/share/nginx/html/"
docker exec dashboard test ! -f /usr/share/nginx/html/pegaz.png && docker cp "$PATH_PEGAZ/docs/pegaz.png" "dashboard:/usr/share/nginx/html/"

docker exec dashboard chmod -R 755 /usr/share/nginx/html
