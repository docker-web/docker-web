# Auto-completion: propose les backups présents dans PATH_BACKUP
_restore_completions() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local backups=($(ls -1 "$PATH_BACKUP"/*.tar.gz 2>/dev/null | xargs -n1 basename | sed 's/\.tar\.gz$//'))
  COMPREPLY=( $(compgen -W "${backups[*]}" -- "$cur") )
}
complete -F _restore_completions restore

# Main restore function
RESTORE() {
  local APP=$1 APP_STATE=$(GET_STATE $1) PATH_TMP="$PATH_BACKUP/$1" PATH_ARCHIVE="$PATH_BACKUP/$1.tar.gz"

  if [[ -z "$APP_STATE" ]]; then
    echo "[x] $APP is not running or does not exist"
    return 1
  elif [[ ! -f "$PATH_ARCHIVE" ]]; then
    echo "[x] Backup not found: $PATH_ARCHIVE"
    return 1
  fi

  mkdir -p "$PATH_TMP"
  tar xf "$PATH_ARCHIVE" -C "$PATH_TMP"
  echo "[*] Restoring $APP from $PATH_TMP.tar.gz ..."

  EXECUTE "stop" $APP
  for VOLUME in $(EXECUTE "config --volumes" $APP)
  do
    local VOLUME_NAME="${APP}_${VOLUME}"
    local VOLUME_PATH=($(docker volume inspect --format "{{.Mountpoint}}" $VOLUME_NAME 2> /dev/null))
    docker run --rm -v $VOLUME_PATH:/destination -v $PATH_TMP:/backup busybox sh -c "rm -rf /destination/* && tar xzf /backup/$VOLUME_NAME.tar.gz -C /destination"
  done
  EXECUTE "start" $APP

  rm -rf "$PATH_TMP"
  echo "[√] $APP restore done"
}
