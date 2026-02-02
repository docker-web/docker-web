#!/bin/bash
echo "[*] update launcher"
FOLDER_WEB=$PATH_APPS/launcher/web

echo "" > $FOLDER_WEB/index.html
echo "" > $FOLDER_WEB/body.html
cat "$FOLDER_WEB/top.html" >> "$FOLDER_WEB/index.html"
sed -i "s|__DOMAIN__|$DOMAIN|g" "$FOLDER_WEB/index.html"

# APPS
for APP_PATH in $PATH_APPS/*
do
  APP_NAME=$(basename $APP_PATH)
  APP_NAME=$(echo $APP_NAME | sed "s%/%%g")

  unset LAUNCHER_HIDDEN
  unset DOMAIN
  unset REDIRECTIONS
  unset FROM
  unset TO

  [[ -f "$APP_PATH/env.sh" ]] && source "$APP_PATH/env.sh"
  [[ -f "$APP_PATH/.env" ]] && source "$APP_PATH/.env"
  [[ $LAUNCHER_HIDDEN == true ]] && continue
  if [[ $(docker ps -f "name=$APP_NAME" -f "status=running" --format "{{.Names}}") ]]
  then
    # APPLICATION
    cp -a "$FOLDER_WEB/link.html" "$FOLDER_WEB/$APP_NAME.html"
    sed -i "s|__LINK_TYPE__|application|g" "$FOLDER_WEB/$APP_NAME.html"
    sed -i "s|__NAME__|$APP_NAME|g" "$FOLDER_WEB/$APP_NAME.html"
    sed -i "s|__DOMAIN__|$DOMAIN|g" "$FOLDER_WEB/$APP_NAME.html"
    cat "$FOLDER_WEB/$APP_NAME.html" >> "$FOLDER_WEB/body.html"
    rm "$FOLDER_WEB/$APP_NAME.html"
    if [[ -f "$APP_PATH/logo.svg" ]]
    then
      docker cp "$APP_PATH/logo.svg" "launcher:/usr/share/nginx/html/$APP_NAME.svg" > /dev/null
    else
      docker cp "$PATH_APPS/launcher/docker-web.svg" "launcher:/usr/share/nginx/html/$APP_NAME.svg" > /dev/null
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
          if [[ -f "$APP_PATH/$NAME_REDIRECTION.svg" ]]
          then
            docker exec launcher test ! -f "/usr/share/nginx/html/$NAME_REDIRECTION.svg" && docker cp "$APP_PATH/$NAME_REDIRECTION.svg" "launcher:/usr/share/nginx/html/$NAME_REDIRECTION.svg" > /dev/null
          else
            docker cp "$PATH_APPS/launcher/web/svg/$NAME_REDIRECTION.svg" "launcher:/usr/share/nginx/html/$NAME_REDIRECTION.svg" > /dev/null
          fi
          cat "$FOLDER_WEB/$NAME_REDIRECTION.html" >> "$FOLDER_WEB/body.html"
          rm "$FOLDER_WEB/$NAME_REDIRECTION.html"
        fi
      done
    fi
  fi
done

# EMPTY
if [[ $(cat "$FOLDER_WEB/body.html") == "" ]]
then
  cat "$FOLDER_WEB/empty.html" >> "$FOLDER_WEB/body.html"
else
  # ALIASES
  source "$PATH_APPS/launcher/$FILENAME_ENV"
  if [[ $ALIASES ]]
  then
    for ALIAS in $ALIASES
    do
      NAME_ALIAS=${ALIAS%->*}
      URL_ALIAS=${ALIAS#*->}
      cp -a "$FOLDER_WEB/link.html" "$FOLDER_WEB/$NAME_ALIAS.html"
      sed -i "s|__LINK_TYPE__|alias|g" "$FOLDER_WEB/$NAME_ALIAS.html"
      sed -i "s|__NAME__|$NAME_ALIAS|g" "$FOLDER_WEB/$NAME_ALIAS.html"
      sed -i "s|__DOMAIN__|$URL_ALIAS|g" "$FOLDER_WEB/$NAME_ALIAS.html"
      [[ -f "$PATH_APPS/launcher/web/svg/$NAME_ALIAS.svg" ]] && docker cp "$PATH_APPS/launcher/web/svg/$NAME_ALIAS.svg" "launcher:/usr/share/nginx/html/$NAME_ALIAS.svg" > /dev/null
      cat "$FOLDER_WEB/$NAME_ALIAS.html" >> "$FOLDER_WEB/body.html"
      rm "$FOLDER_WEB/$NAME_ALIAS.html"
    done
  fi
fi

cat "$FOLDER_WEB/body.html" >> "$FOLDER_WEB/index.html"
cat "$FOLDER_WEB/bottom.html" >> "$FOLDER_WEB/index.html"

docker cp "$FOLDER_WEB/index.html" "launcher:/usr/share/nginx/html/" > /dev/null
docker exec launcher test ! -f /usr/share/nginx/html/docker-web.svg && docker cp "$PATH_APPS/launcher/web/svg/docker-web.svg" "launcher:/usr/share/nginx/html/" > /dev/null
docker exec launcher chmod -R 755 /usr/share/nginx/html
