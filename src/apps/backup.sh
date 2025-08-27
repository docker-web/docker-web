# Helper for remote backup
REMOTE_BACKUP() {
  local APP="$1"
  local REMOTE="$2"

  # Locate remote env.sh
  local REMOTE_ENV=$(ssh "$REMOTE" 'find ~ -type f -path "*/docker-web/src/env.sh" 2>/dev/null | head -n1')
  if [[ -z "$REMOTE_ENV" ]]; then
    echo "[x] Could not find docker-web on remote $REMOTE"
    return 1
  fi

  # Get remote backup path
  local REMOTE_PATH=$(ssh "$REMOTE" "source $REMOTE_ENV && echo \$PATH_DOCKERWEB_BACKUP")
  if [[ -z "$REMOTE_PATH" ]]; then
    echo "[x] Could not determine remote backup path"
    return 1
  fi

  # Ask before overwriting remote backup
  if ssh "$REMOTE" "[ -f $REMOTE_PATH/$APP.tar.gz ]"; then
    read -p "[!] Remote backup exists on $REMOTE. Overwrite? [y/N] " CONFIRM
    [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]] && echo "Abort." && return 1
  fi

  # Copy backup to remote
  scp "$PATH_DOCKERWEB_BACKUP/$APP.tar.gz" "$REMOTE:$REMOTE_PATH/"
  echo "[√] Backup $APP copied to $REMOTE"
}

# Main backup function
BACKUP() {
  local APP="$1"
  local REMOTE="$2"  # optional remote host if provided

  APP_STATE=$(GET_STATE $APP)
  if [[ -z "$APP_STATE" ]]; then
    echo "[x] $APP is not running or does not exist"
    return 1
  fi

  echo "[*] Backup $APP"
  local PATH_BACKUP_APP="$PATH_DOCKERWEB_BACKUP/$APP"
  mkdir -p "$PATH_BACKUP_APP"

  # Backup app folder
  cd "$PATH_DOCKERWEB_APPS/$APP" && tar czf "$PATH_BACKUP_APP/app.tar.gz" *

  # Up & pause
  [[ -z $(GET_STATE $APP) ]] && EXECUTE "up -d" $APP
  EXECUTE "pause" $APP

  # Backup volumes
  for VOLUME in $(EXECUTE "config --volumes" $APP); do
    local VOL_INFO=($(docker volume inspect --format "{{.Name}} {{.Mountpoint}}" "$APP_$VOLUME" 2>/dev/null))
    local VOL_NAME=${VOL_INFO[0]}
    if [[ -n "$VOL_NAME" ]]; then
      docker run --rm -v $VOL_NAME:/$VOL_NAME -v $PATH_BACKUP_APP:/backup busybox tar czf /backup/$VOL_NAME.tar.gz /$VOL_NAME 2>/dev/null
    fi
  done

  # Create local tar.gz
  cd "$PATH_BACKUP_APP" && tar czf "$PATH_DOCKERWEB_BACKUP/$APP.tar.gz" *

  EXECUTE "unpause" $APP
  rm -rf "$PATH_BACKUP_APP"

  echo "[√] Local backup $APP done"

  # If remote host provided, use helper
  [[ -n "$REMOTE" ]] && REMOTE_BACKUP "$APP" "$REMOTE"
}
