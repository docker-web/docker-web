#!/bin/bash
echo "[*] update dashboard"
FOLDER_WEB="$PATH_PEGAZ_SERVICES/dashboard/web"

echo "" > $FOLDER_WEB/index.html
echo "" > $FOLDER_WEB/body.html
source "$PATH_PEGAZ_SERVICES/radio/$FILENAME_CONFIG"
sed -i "s|__DOMAIN_RADIO__|$DOMAIN|g" "$FOLDER_WEB/top.html"
sed -i "s|__TITLE__|$MAIN_DOMAIN|g" "$FOLDER_WEB/top.html"
cat "$FOLDER_WEB/top.html" >> "$FOLDER_WEB/index.html"

for PATH_SERVICE in $PATH_PEGAZ_SERVICES/*
do
  NAME_SERVICE=$(basename $PATH_SERVICE)
  NAME_SERVICE=$(echo $NAME_SERVICE | sed "s%/%%g")

  unset DASHBOARD_HIDDEN
  unset DOMAIN

  [[ -f "$PATH_SERVICE/$FILENAME_CONFIG" ]] && source "$PATH_SERVICE/$FILENAME_CONFIG"
  [[ -f "$PATH_SERVICE/$FILENAME_ENV" ]] && source "$PATH_SERVICE/$FILENAME_ENV"
  [[ $DASHBOARD_HIDDEN == true ]] && continue
  if [[ $(docker ps -f "name=$NAME_SERVICE" -f "status=running" --format "{{.Names}}") ]]
  then
    [[ $NAME_SERVICE == "radio" ]] && cp -a "$FOLDER_WEB/link-radio.html" "$FOLDER_WEB/$NAME_SERVICE.html" || cp -a "$FOLDER_WEB/link.html" "$FOLDER_WEB/$NAME_SERVICE.html"
    sed -i "s|__NAME__|$NAME_SERVICE|g" "$FOLDER_WEB/$NAME_SERVICE.html"
    sed -i "s|__DOMAIN__|$DOMAIN|g" "$FOLDER_WEB/$NAME_SERVICE.html"
    cat "$FOLDER_WEB/$NAME_SERVICE.html" >> "$FOLDER_WEB/body.html"
    if [[ -f "$PATH_SERVICE/logo.svg" ]]
    then
      docker exec dashboard test ! -f "/usr/share/nginx/html/$NAME_SERVICE.svg" && docker cp "$PATH_SERVICE/logo.svg" "dashboard:/usr/share/nginx/html/$NAME_SERVICE.svg"
    fi
  fi
done

[[ $(cat "$FOLDER_WEB/body.html") == "" ]] && cat "$FOLDER_WEB/empty.html" >> "$FOLDER_WEB/body.html"

cat "$FOLDER_WEB/body.html" >> "$FOLDER_WEB/index.html"
cat "$FOLDER_WEB/bottom.html" >> "$FOLDER_WEB/index.html"

docker cp "$FOLDER_WEB/index.html" "dashboard:/usr/share/nginx/html/"
docker exec dashboard test ! -f /usr/share/nginx/html/pegaz.svg && docker cp "$PATH_PEGAZ/docs/pegaz.svg" "dashboard:/usr/share/nginx/html/"
docker exec dashboard test ! -f /usr/share/nginx/html/pegaz.png && docker cp "$PATH_PEGAZ/docs/pegaz.png" "dashboard:/usr/share/nginx/html/"

docker exec dashboard chmod -R 755 /usr/share/nginx/html
