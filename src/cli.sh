#!/bin/bash
source /var/docker-web/config.sh
source /var/docker-web/src/env.sh

WORK_DIR=$(pwd)
export WORK_DIR

# Charger helpers
for f in "$PATH_DOCKERWEB/src/helpers/"*.sh; do [ -f "$f" ] && source "$f"; done
# Charger core
for f in "$PATH_DOCKERWEB/src/core/"*.sh; do [ -f "$f" ] && source "$f"; done
# Charger apps
for f in "$PATH_DOCKERWEB/src/apps/"*.sh; do [ -f "$f" ] && source "$f"; done

# --- Préparer store + apps locales ---
LOCAL_DOCKERWEB_STORE="$PATH_DOCKERWEB/store"
mkdir -p "$LOCAL_DOCKERWEB_STORE"
INDEX_FILE="$LOCAL_DOCKERWEB_STORE/index.json"

# Rafraîchissement automatique si absent ou vieux de >1h
if [ ! -f "$INDEX_FILE" ] || [ $(($(date +%s) - $(stat -c %Y "$INDEX_FILE"))) -gt 3600 ]; then
  curl -s -o "$INDEX_FILE" "$URL_DOCKERWEB_STORE/index.json"
fi

# Apps store en tableau
if [ -f "$INDEX_FILE" ]; then
  if command -v jq >/dev/null 2>&1; then
    mapfile -t APPS_STORE < <(jq -r '.apps[].name' "$INDEX_FILE" 2>/dev/null | sort -u)
  else
    mapfile -t APPS_STORE < <(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$INDEX_FILE" | sed -E 's/.*"name"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' | sort -u)
  fi
else
  APPS_STORE=()
fi

# Apps locales en tableau
if [ -d "$PATH_DOCKERWEB_APPS" ]; then
  mapfile -t APPS_LOCAL < <(find "$PATH_DOCKERWEB_APPS" -mindepth 1 -maxdepth 1 -not -name '.*' -type d -exec basename {} \; | sort -u)
else
  APPS_LOCAL=()
fi

# Apps non installées
APPS_NOT_INSTALLED=()
for app in "${APPS_STORE[@]}"; do
  if [[ ! " ${APPS_LOCAL[*]} " =~ " $app " ]]; then
    APPS_NOT_INSTALLED+=("$app")
  fi
done

# --- Commandes exceptionnelles ---
handle_exception() {
  local cmd="$1"
  local arg="$2"

  case "$cmd" in
    ps)
      if [ -n "$arg" ]; then EXECUTE "$cmd" "$arg"; else for APP in "${APPS[@]}"; do EXECUTE "$cmd" "$APP"; done; fi
      ;;

    backup)
      if [ "$arg" == "ls" ]; then
        echo -e "$(ls -lth "$PATH_DOCKERWEB_BACKUP")"
      elif [ -n "$arg" ]; then
        BACKUP "$arg"
      else
        for APP in "${APPS[@]}"; do BACKUP "$APP"; done
      fi
      ;;

    dl)
      if [ -n "$arg" ]; then
        if [[ " ${APPS_NOT_INSTALLED[*]} " =~ " $arg " ]]; then
          DL "$arg"
        else
          echo "[x] $arg is already installed or not in store"
        fi
      else
        echo "[x] dl requires an app argument"
      fi
      ;;

    install)
      if [ -n "$arg" ]; then
        if [[ " ${APPS_NOT_INSTALLED[*]} " =~ " $arg " ]]; then
          DL "$arg"
        fi
        UP "$arg"
      else
        echo "[x] install requires an app argument"
      fi
      ;;

    *)
      return 1
      ;;
  esac
  return 0
}

# --- Dispatch principal ---
if [ -z "$1" ]; then
  HELP

elif handle_exception "$1" "$2"; then
  exit 0

elif [[ " ${COMMANDS[*]} " =~ " $1 " ]]; then

  # --- CORE commands ---
  if [[ " ${COMMANDS_CORE[*]} " =~ " $1 " ]]; then
    if [ -z "$2" ]; then
      "${1^^}"
    elif [[ "$1" == "create" || "$1" == "init" ]]; then
      "${1^^}" "$2" "$3"
    else
      echo "[x] $1 command doesn't need param, try to run 'docker-web $1'"
    fi

# --- APP commands ---
elif [[ " ${COMMANDS_APP[*]} " =~ " $1 " ]]; then
  if [ -z "$2" ]; then
    # Warn user before executing the command on all local apps
    if [[ "$1" == "backup" || "$1" == "restore" ]]; then
      echo "[! WARNING] You are about to run '$1' on all local apps."
      read -p "Continue? (y/N) " CONFIRM
      [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]] && echo "Cancelled." && exit 0
    fi

    for APP in $APPS; do
      ${1^^} $APP
    done
  else
    # Handle remote restore/backup
    if [[ "$1" == "restore" && "$2" == "--remote" && -n "$3" ]]; then
      REMOTE_HOST="$3"
      APP_NAME="$4"
      ${1^^} "$APP_NAME" "$REMOTE_HOST"
    elif [[ "$1" == "backup" && "$2" == "--remote" && -n "$3" ]]; then
      REMOTE_HOST="$3"
      APP_NAME="$4"
      ${1^^} "$APP_NAME" "$REMOTE_HOST"
    else
      # Check if the specified app exists locally
      if [[ " ${APPS_FLAT[*]} " =~ " $2 " ]]; then
        ${1^^} $2
      else
        echo "[x] $2 n'existe pas. Apps disponibles : $APPS_FLAT"
      fi
    fi
  fi

  # --- DOCKER-COMPOSE commands ---
  else
    if [ -n "$2" ]; then
      EXECUTE "$1" "$2"
    else
      for APP in "${APPS[@]}"; do
        EXECUTE "$1" "$APP"
      done
    fi
  fi

# --- CLI functions ---
elif FUNCTION_EXISTS "$1"; then
  "$@"

else
  echo "[x] No such command: $1"
fi
