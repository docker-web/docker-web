BACKUP() {
  local APP=$1 APP_STATE=$(GET_STATE $1) PATH_TMP="$PATH_BACKUP/$1"

  if [[ -z "$APP_STATE" ]]; then
    echo "[x] $APP is not running or does not exist"
    return 1
  elif [[ -z $(EXECUTE "config --volumes" $APP) ]]; then
    echo "[*] $APP has no volumes to backup"
    return 1
  fi

  echo "[*] Backup $APP"
  mkdir -p "$PATH_BACKUP"
  mkdir -p "$PATH_TMP"

  EXECUTE "pause" $APP
  for VOLUME in $(EXECUTE "config --volumes" $APP)
  do
    local VOLUME_NAME="${APP}_${VOLUME}"
    local VOLUME_PATH=($(docker volume inspect --format "{{.Mountpoint}}" $VOLUME_NAME 2> /dev/null))
    docker run --rm -v $VOLUME_PATH:/volume -v $PATH_TMP:/tmp busybox sh -c "cd /volume && tar czf /tmp/$VOLUME_NAME.tar.gz *" 2>/dev/null
  done
  EXECUTE "unpause" $APP

  cd "$PATH_TMP" && tar czf "$PATH_BACKUP/$APP.tar.gz" *

  rm -rf "$PATH_TMP"

  echo "[√] backup $APP done"
}
