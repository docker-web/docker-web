#!/bin/bash

_pegaz_completions() {
  source "/etc/pegaz/env.sh"
  SERVICES=$(find $PATH_PEGAZ_SERVICES -mindepth 1 -maxdepth 1 -not -name '.*' -type d -printf '  %f\n' | sort | sed '/^$/d')
  COMMANDS="$COMMANDS_CORE $COMMANDS_SERVICE $COMMANDS_COMPOSE"

  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  if test $COMP_CWORD -eq 1
  then
    COMPREPLY=( $(compgen -W "${COMMANDS[*]}" -- ${cur}) )
  elif test $COMP_CWORD -eq 2
  then
    case "$prev" in
      uninstall | upgrade) return 0;;
      *) COMPREPLY=($(compgen -W "$SERVICES" -- ${cur}));;
    esac
  fi

  return 0
}

complete -F _pegaz_completions pegaz pegazdev
