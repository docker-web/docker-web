#!/usr/bin/env bash

# Auto-completion: propose les backups présents dans PATH_DOCKERWEB_BACKUP
_restore_completions() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local backups=($(ls -1 "$PATH_DOCKERWEB_BACKUP"/*.tar.gz 2>/dev/null | xargs -n1 basename | sed 's/\.tar\.gz$//'))
  COMPREPLY=( $(compgen -W "${backups[*]}" -- "$cur") )
}
complete -F _restore_completions restore

# Helper to fetch backup from remote host
REMOTE_RESTORE() {
  local APP="$1"
  local REMOTE="$2"
  local SSH_CMD="ssh -o LogLevel=QUIET $REMOTE"

  local REMOTE_ENV=$($SSH_CMD "LC_ALL=C find ~ -type f -path '*/docker-web/src/env.sh' 2>/dev/null | head -n1")
  [[ -z "$REMOTE_ENV" ]] && { echo "[x] Could not find docker-web on remote $REMOTE"; return 1; }

  local REMOTE_BACKUP_PATH=$($SSH_CMD "LC_ALL=C source $REMOTE_ENV && echo \$PATH_DOCKERWEB_BACKUP")
  [[ -z "$REMOTE_BACKUP_PATH" ]] && { echo "[x] Could not determine remote backup path"; return 1; }

  local LOCAL_BACKUP="$PATH_DOCKERWEB_BACKUP/$APP.tar.gz"
  if [[ -f "$LOCAL_BACKUP" ]]; then
    read -p "[!] Local backup exists. Overwrite? [y/N] " CONFIRM
    [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]] && return 1
  fi

  scp "$REMOTE:$REMOTE_BACKUP_PATH/$APP.tar.gz" "$LOCAL_BACKUP" >/dev/null 2>&1 || {
    echo "[x] Failed to fetch remote backup"
    return 1
  }

  echo "$LOCAL_BACKUP"
}

# Main restore function
RESTORE() {
  local APP="$1"
  local REMOTE="$2"

  local LOCAL_BACKUP="$PATH_DOCKERWEB_BACKUP/$APP.tar.gz"
  if [[ -n "$REMOTE" ]]; then
    echo "[*] Fetching $APP backup from $REMOTE..."
    LOCAL_BACKUP=$(REMOTE_RESTORE "$APP" "$REMOTE") || return 1
    echo "[√] Backup $APP fetched from $REMOTE"
  fi

  [[ ! -f "$LOCAL_BACKUP" ]] && { echo "[x] Backup not found: $LOCAL_BACKUP"; return 1; }

  local BACKUP_DIR="$PATH_DOCKERWEB_BACKUP/$APP"
  mkdir -p "$BACKUP_DIR"
  echo "[*] Restoring $APP from $LOCAL_BACKUP..."

  tar xf "$LOCAL_BACKUP" -C "$BACKUP_DIR"

  if [[ -f "$BACKUP_DIR/app.tar.gz" ]]; then
    mkdir -p "$PATH_DOCKERWEB_APPS/$APP"
    rm -rf "$PATH_DOCKERWEB_APPS/$APP"/*
    tar xf "$BACKUP_DIR/app.tar.gz" -C "$PATH_DOCKERWEB_APPS/$APP"
  fi

  if [[ -n $(GET_STATE $APP) ]]; then
    EXECUTE "stop" $APP
  fi

  for VOLUME in $(EXECUTE "config --volumes" $APP); do
    local VOL_INFO=($(docker volume inspect --format "{{.Name}} {{.Mountpoint}}" "$APP_$VOLUME" 2>/dev/null))
    local VOL_NAME=${VOL_INFO[0]}
    if [[ -n "$VOL_NAME" ]]; then
      docker run --rm -v $VOL_NAME:/$VOL_NAME -v $BACKUP_DIR:/backup busybox \
        sh -c "cd /$VOL_NAME && tar xf /backup/$VOL_NAME.tar.gz --strip 1"
    fi
  done

  UP $APP
  rm -rf "$BACKUP_DIR"
  echo "[√] $APP restore done"
}
