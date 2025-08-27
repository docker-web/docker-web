#!/bin/bash

_docker-web() {
  source /var/docker-web/src/env.sh

  local cur prev prev_prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  prev_prev="${COMP_WORDS[COMP_CWORD-2]}"

  # Apps locales
  if [ -d "$PATH_DOCKERWEB_APPS" ]; then
    APPS_LOCAL=$(find "$PATH_DOCKERWEB_APPS" -mindepth 1 -maxdepth 1 -not -name '.*' -type d -exec basename {} \; | sort | sed '/^$/d')
  else
    APPS_LOCAL=""
  fi

  # Store : URL et local
  LOCAL_DOCKERWEB_STORE="$PATH_DOCKERWEB/store"
  mkdir -p "$LOCAL_DOCKERWEB_STORE"
  INDEX_FILE="$LOCAL_DOCKERWEB_STORE/index.json"

  # Rafraîchissement automatique si absent ou vieux de >1h
  if [ ! -f "$INDEX_FILE" ] || [ $(($(date +%s) - $(stat -c %Y "$INDEX_FILE"))) -gt 3600 ]; then
    curl -s -o "$INDEX_FILE" "$URL_DOCKERWEB_STORE/index.json"
  fi

  # Lecture apps store
  if [ -f "$INDEX_FILE" ]; then
    if command -v jq >/dev/null 2>&1; then
      APPS_STORE=$(jq -r '.apps[].name' "$INDEX_FILE" 2>/dev/null | sort -u)
    else
      APPS_STORE=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$INDEX_FILE" | sed -E 's/.*"name"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' | sort -u)
    fi
  else
    APPS_STORE=""
  fi

  # Diff store - local pour dl/install
  if [ -n "$APPS_STORE" ]; then
    APPS_NOT_INSTALLED=$(comm -23 <(echo "$APPS_STORE") <(echo "$APPS_LOCAL"))
  else
    APPS_NOT_INSTALLED=""
  fi

  # --- DEBUG LOGS (à enlever en prod) ---
  # echo "[DEBUG] APPS_LOCAL=$APPS_LOCAL" >&2
  # echo "[DEBUG] APPS_STORE=$APPS_STORE" >&2
  # echo "[DEBUG] APPS_NOT_INSTALLED=$APPS_NOT_INSTALLED" >&2
  # echo "[DEBUG] COMP_CWORD=$COMP_CWORD cur='$cur' prev='$prev'" >&2
  # ------------------

  # Complétion
  if [ $COMP_CWORD -eq 1 ]; then
    # premier mot après la commande principale
    COMPREPLY=( $(compgen -W "${COMMANDS[*]}" -- "$cur") )

  elif [ $COMP_CWORD -eq 2 ]; then
    # si le mot précédent est dl ou install, proposer les apps non installées
    if [[ "$prev" == "dl" || "$prev" == "install" ]]; then
      COMPREPLY=( $(compgen -W "$APPS_NOT_INSTALLED" -- "$cur") )
    elif [[ " ${COMMANDS_CORE} " =~ " ${prev} " ]]; then
      COMPREPLY=()
    else
      COMPREPLY=( $(compgen -W "$APPS_LOCAL" -- "$cur") )
    fi

  elif [ $COMP_CWORD -eq 3 ]; then
    case "$prev_prev" in
      create)
        IMAGES=$(docker search "$prev" --limit 20 --format "{{.Name}}" 2>/dev/null)
        COMPREPLY=( $(compgen -W "$IMAGES" -- "$cur") )
        ;;
    esac
  fi

  return 0
}

complete -F _docker-web docker-web dweb
