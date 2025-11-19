#!/bin/bash

_docker-web() {
  source /var/docker-web/src/env.sh

  local cur prev prev_prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  prev_prev="${COMP_WORDS[COMP_CWORD-2]}"

  if [ $COMP_CWORD -eq 1 ]; then
    # premier mot après la commande principale
    COMPREPLY=( $(compgen -W "${COMMANDS[*]}" -- "$cur") )

  elif [ $COMP_CWORD -eq 2 ]; then
    if [[ "$prev" == "install" ]]; then
      COMPREPLY=( $(compgen -W "$APPS_FLAT" -- "$cur") )
    elif [[ " ${COMMANDS_CORE} " =~ " ${prev} " ]]; then
      COMPREPLY=()
    else
      COMPREPLY=( $(compgen -W "$APPS_FLAT" -- "$cur") )
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
