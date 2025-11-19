BACKUP() {
  local APP APP_STATE

  APP=$1
  APP_STATE=$(GET_STATE $APP)

  if [[ -z "$APP_STATE" ]]; then
    echo "[x] $APP is not running or does not exist"
    return 1
  elif [[ -z $(EXECUTE "config --volumes" $APP) ]]; then
    echo "[*] $APP has no volumes to backup"
    return 1
  fi

  echo "[*] Backup $APP"
  local PATH_BACKUP_APP="$PATH_DOCKERWEB_BACKUP/$APP"
  mkdir -p "$PATH_BACKUP_APP"

  [[ -z $(GET_STATE $APP) ]] && EXECUTE "up -d" $APP
  EXECUTE "pause" $APP

  for VOLUME in $(EXECUTE "config --volumes" $APP); do
    local VOL_NAME="${APP}_${VOLUME}"
    docker run --rm -v $VOL_NAME:/$VOL_NAME -v $PATH_BACKUP_APP:/backup busybox tar czf /backup/$VOL_NAME.tar.gz /$VOL_NAME 2>/dev/null
  done

  cd "$PATH_BACKUP_APP" && tar czf "$PATH_DOCKERWEB_BACKUP/$APP.tar.gz" *

  EXECUTE "unpause" $APP
  rm -rf "$PATH_BACKUP_APP"

  echo "[√] Local backup $APP done"
}
