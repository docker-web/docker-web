#!/bin/bash
echo "[*] update dashboard"
FOLDER_WEB="$PATH_PEGAZ_SERVICES/$1/web"
RUNNING_SERVICE_LIST=$(docker ps -f "status=running" --format "{{.Names}}")
RUNNING_SERVICE_LIST=${RUNNING_SERVICE_LIST/proxy-acme/}
RUNNING_SERVICE_LIST=${RUNNING_SERVICE_LIST/proxy/}
RUNNING_SERVICE_LIST=${RUNNING_SERVICE_LIST/dashboard/}
RUNNING_SERVICE_LIST=${RUNNING_SERVICE_LIST/test/}
RUNNING_SERVICE_LIST=${RUNNING_SERVICE_LIST//[^a-zA-Z0-9_]/}

echo "" > $FOLDER_WEB/index.html
sed -i "s|__TITLE__|$SITE_TITLE|g" "$FOLDER_WEB/top.html"

cat "$FOLDER_WEB/top.html" >> "$FOLDER_WEB/index.html"

if [[ -z $RUNNING_SERVICE_LIST ]]
then
  cat "$FOLDER_WEB/empty.html" >> "$FOLDER_WEB/index.html"
else
  for PATH_SERVICE in $PATH_PEGAZ_SERVICES/*
  do
    NAME_SERVICE=$(basename $PATH_SERVICE)
    NAME_SERVICE=$(echo $NAME_SERVICE | sed "s%/%%g")

    if [[ $NAME_SERVICE != "proxy" && $NAME_SERVICE != "dashboard" && $NAME_SERVICE != "test" ]]
    then
      if [[ -f "$PATH_SERVICE/logo.svg" ]]
      then
        docker cp "$PATH_SERVICE/logo.svg" "$1:/usr/share/nginx/html/$NAME_SERVICE.svg"
      fi
      if [[ "$RUNNING_SERVICE_LIST" =~ $NAME_SERVICE ]]
      then
        [[ -f "$PATH_SERVICE/$FILENAME_CONFIG" ]] && source "$PATH_SERVICE/$FILENAME_CONFIG"
        [[ -f "$PATH_SERVICE/$FILENAME_ENV" ]] && source "$PATH_SERVICE/$FILENAME_ENV"
        if [[ $DASHBOARD_HIDDEN != true ]]
          then
          if [[ $NAME_SERVICE == "radio" ]]
          then
            cp "$FOLDER_WEB/link-radio.html" "$FOLDER_WEB/$NAME_SERVICE.html"
          else
            cp "$FOLDER_WEB/link.html" "$FOLDER_WEB/$NAME_SERVICE.html"
          fi
          sed -i "s|__NAME__|$NAME_SERVICE|g" "$FOLDER_WEB/$NAME_SERVICE.html"
          sed -i "s|__DOMAIN__|$DOMAIN|g" "$FOLDER_WEB/$NAME_SERVICE.html"
          sed -i "s|__DOMAIN_LIQ__|$DOMAIN_LIQ|g" "$FOLDER_WEB/$NAME_SERVICE.html"
          cat "$FOLDER_WEB/$NAME_SERVICE.html" >> "$FOLDER_WEB/index.html"
        fi
      fi
    fi
  done
fi

cat "$FOLDER_WEB/bottom.html" >> "$FOLDER_WEB/index.html"

docker cp "$FOLDER_WEB/index.html" "$1:/usr/share/nginx/html/"
docker cp "$PATH_PEGAZ/docs/pegaz.svg" "$1:/usr/share/nginx/html/"
docker cp "$PATH_PEGAZ/docs/pegaz.png" "$1:/usr/share/nginx/html/"

docker exec dashboard chmod -R 755 /usr/share/nginx/html
