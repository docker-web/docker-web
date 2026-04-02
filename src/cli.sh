#!/bin/bash
source /var/docker-web/config.sh
source /var/docker-web/src/env.sh

WORK_DIR=$(pwd)
export WORK_DIR

# load deps
for f in "$PATH_DOCKERWEB/src/core/"*.sh; do [ -f "$f" ] && source "$f"; done
for f in "$PATH_DOCKERWEB/src/apps/"*.sh; do [ -f "$f" ] && source "$f"; done
for f in "$PATH_DOCKERWEB/src/helpers/"*.sh; do [ -f "$f" ] && source "$f"; done

# --- Dispatch principal ---
if [ -z "$1" ]; then
  HELP

elif [[ " ${COMMANDS[*]} " =~ " $1 " ]]; then

  # --- CORE commands ---
  if [[ " ${COMMANDS_CORE[*]} " =~ " $1 " ]]; then
    if [ -z "$2" ]; then
      "${1^^}"
    elif [[ "$1" == "create" || "$1" == "init" || "$1" == "dl" ]]; then
      "${1^^}" "$2" "$3"
    else
      echo "[x] $1 command doesn't need param, try to run 'docker-web $1'"
    fi

# --- APP commands ---
elif [[ " ${COMMANDS_APP[*]} " =~ " $1 " ]]; then
  if [ -z "$2" ]; then
    for APP in $APPS; do
      ${1^^} $APP
    done
  else
    # Handle -y flag for rm command (both positions)
    if [ "$1" = "rm" ]; then
      if [ "$2" = "-y" ] && [ -n "$3" ]; then
        # dweb rm -y wordpress
        if [[ " ${APPS_FLAT[*]} " =~ " $3 " ]]; then
          ${1^^} "$3" "$2"
        else
          echo "[x] $3 n'existe pas. Apps disponibles : $APPS_FLAT"
        fi
      elif [ "$3" = "-y" ] && [ -n "$2" ]; then
        # dweb rm wordpress -y
        if [[ " ${APPS_FLAT[*]} " =~ " $2 " ]]; then
          ${1^^} "$2" "$3"
        else
          echo "[x] $2 n'existe pas. Apps disponibles : $APPS_FLAT"
        fi
      elif [[ " ${APPS_FLAT[*]} " =~ " $2 " ]]; then
        # dweb rm wordpress (no flag)
        ${1^^} $2
      else
        echo "[x] $2 n'existe pas. Apps disponibles : $APPS_FLAT"
      fi
    elif [[ " ${APPS_FLAT[*]} " =~ " $2 " ]]; then
      ${1^^} $2
    else
      echo "[x] $2 n'existe pas. Apps disponibles : $APPS_FLAT"
    fi
  fi

  # --- DOCKER-COMPOSE commands ---
  else
    if [ -n "$2" ]; then
      EXECUTE "$1" "$2"
    else
      echo "$APPS" | while IFS= read -r APP; do
        [ -n "$APP" ] && EXECUTE "$1" "$APP"
      done
    fi
  fi

# --- CLI functions ---
elif FUNCTION_EXISTS "$1"; then
  "$@"

else
  echo "[x] No such command: $1"
fi
