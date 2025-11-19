# Auto-completion: propose les backups présents dans PATH_DOCKERWEB_BACKUP
_restore_completions() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local backups=($(ls -1 "$PATH_DOCKERWEB_BACKUP"/*.tar.gz 2>/dev/null | xargs -n1 basename | sed 's/\.tar\.gz$//'))
  COMPREPLY=( $(compgen -W "${backups[*]}" -- "$cur") )
}
complete -F _restore_completions restore

# Main restore function
RESTORE() {
  local APP="$1"
  local BACKUP_ARCHIVE="$PATH_DOCKERWEB_BACKUP/$APP.tar.gz"

  [[ ! -f "$BACKUP_ARCHIVE" ]] && { echo "[x] Backup not found: $BACKUP_ARCHIVE"; return 1; }

  [[ $(EXECUTE "status" $APP) != "running" ]] && UP $APP

  local TEMP_DIR="$PATH_DOCKERWEB_BACKUP/$APP"
  mkdir -p "$TEMP_DIR"
  tar xf "$BACKUP_ARCHIVE" -C "$TEMP_DIR"
  echo "[*] Restoring $APP from $BACKUP_ARCHIVE..."

  EXECUTE "stop" $APP

  for VOLUME in $(EXECUTE "config --volumes" $APP); do
    local VOL_NAME="${APP}_${VOLUME}"
    docker run --rm -v $VOL_NAME:/$VOL_NAME -v $TEMP_DIR:/backup busybox \
      sh -c "cd /$VOL_NAME && tar xf /backup/$VOL_NAME.tar.gz --strip 1"
  done

  EXECUTE "start" $APP

  rm -rf "$TEMP_DIR"
  echo "[√] $APP restore done"
}
